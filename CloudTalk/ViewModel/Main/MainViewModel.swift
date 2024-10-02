//
//  MainViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/27.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class MainViewModel: ObservableObject {
    
    @Published var users = [AppUser]()
    @Published var queriedUsers = [AppUser]()
    
    // 필터 정보들
    @Published var gender: Gender?
    @Published var region: Region?
    @Published var ageRange: ClosedRange<Float> = 18...99
    
    let defaults = UserDefaults.standard
    var query: Query = COLLECTION_USERS
    
    init() {
        Task {
            await loadUsers()
        }
    }
    
    func loadUsers() async {
        setFilter()
        setQuery()
        do {
            let users = try await fetchUsers()
            DispatchQueue.main.async {
                self.queriedUsers = users
            }
        } catch {
            print(error.localizedDescription)
        }
    }
    
    private func setFilter() {
        let gender = defaults.integer(forKey: DEFAULTS_MAIN_GENDER)
        let region = defaults.integer(forKey: DEFAULTS_MAIN_REGION)
        let lowerBound = defaults.float(forKey: DEFAULTS_MAIN_AGERANGE_LOWERBOUND)
        let upperBound = defaults.float(forKey: DEFAULTS_MAIN_AGERANGE_UPPERBOUND)
        
        if lowerBound == 0 && upperBound == 0 {
            return
        }
        
        DispatchQueue.main.async {
            self.gender = gender != -1 ? Gender(rawValue: gender) : nil
            self.region = region != -1 ? Region(rawValue: region) : nil
            self.ageRange = lowerBound...upperBound
        }
    }
    
    private func setQuery() {
        
        if let gender = gender, let region = region {
            query = COLLECTION_USERS
                .whereField(KEY_GENDER, isEqualTo: gender.rawValue)
                .whereField(KEY_REGION, isEqualTo: region.rawValue)
        } else if let gender = gender, region == nil {
            query = COLLECTION_USERS
                .whereField(KEY_GENDER, isEqualTo: gender.rawValue)
        } else if let region = region, gender == nil {
            query = COLLECTION_USERS
                .whereField(KEY_REGION, isEqualTo: region.rawValue)
        } else {
            query = COLLECTION_USERS
        }
        
    }
    
    private func getQueriedUsers(users: [AppUser]) -> [AppUser] {
        let lowerBound = Int(ageRange.lowerBound)
        let upperBound = Int(ageRange.upperBound)
        
        /// 18 ~ 99로 세팅된 경우에는 비공개(-1)된 나이도 가져온다.
        if lowerBound == 18 && upperBound == 99 {
            return users.filter({ $0.age >= -1 && $0.age <= upperBound })
        } else {
            return users.filter({ $0.age >= lowerBound && $0.age <= upperBound })
        }
    }
    
    private func fetchUsers() async throws -> [AppUser] {
        print("유저 가져오기 실행")
        let snapshot = try? await query
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 10 + AuthViewModel.shared.blackUids.count)
            .getDocuments()
                
        guard let documents = snapshot?.documents else { return [] }
        
        let users = documents.compactMap { try? $0.data(as: AppUser.self) }
            .filter { $0.id != Auth.auth().currentUser?.uid }
            .filter { !AuthViewModel.shared.blackUids.contains($0.id ?? "") }
            .filter { $0.id != M_KEY}

        DispatchQueue.main.async {
            self.users.removeAll()
        }

        return self.getQueriedUsers(users: users)
    }
    
    func fetchMoreUsers(user: AppUser) async {
        let blackUserCount = AuthViewModel.shared.blackUids.count
        guard user.id == queriedUsers.last?.id else { return }
        print("더 가져오기 실행")
        guard let lastDoc = try? await COLLECTION_USERS.document(queriedUsers.last?.id ?? "").getDocument() else { return DocumentSnapshot.initialize() }
        
        let snapshot = try? await query
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 10 + blackUserCount)
            .start(afterDocument: lastDoc)
            .getDocuments()
        
        guard let documents = snapshot?.documents else { return }
        
        let users = documents.compactMap { try? $0.data(as: AppUser.self) }
            .filter { $0.id != Auth.auth().currentUser?.uid }
            .filter { !AuthViewModel.shared.blackUids.contains($0.id ?? "") }
            .filter { $0.id != M_KEY}
        
        DispatchQueue.main.async {
            self.users.removeAll()
            self.users = self.queriedUsers
            self.users += users
            self.queriedUsers += self.getQueriedUsers(users: users)
        }
    }
    
    func storeFilterValue(gender: Gender?, region: Region?, ageRange: ClosedRange<Float>) async {
                
        // UserDefaults에 적용한 filter값 저장 (-1 = 전체)
        defaults.setValue(gender?.rawValue ?? -1, forKey: DEFAULTS_MAIN_GENDER)
        defaults.setValue(region?.rawValue ?? -1, forKey: DEFAULTS_MAIN_REGION)
        defaults.setValue(ageRange.lowerBound, forKey: DEFAULTS_MAIN_AGERANGE_LOWERBOUND)
        defaults.setValue(ageRange.upperBound, forKey: DEFAULTS_MAIN_AGERANGE_UPPERBOUND)
        
        DispatchQueue.main.async {
            self.queriedUsers.removeAll()
            self.users.removeAll()
        }
        
    }
}
