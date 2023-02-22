//
//  MainViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/27.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class MainViewModel: ObservableObject {
    
    @Published var users = [User]()
    @Published var queriedUsers = [User]()
    
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
        await setFilter()
        await setQuery()
        await fetchUsers()
    }
    
    private func setFilter() async {
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
        print(gender, region, ageRange)
    }
    
    private func setQuery() async {
        
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
    
    private func setQueriedUsers() {
        self.queriedUsers = self.users.filter({ $0.age >= Int(ageRange.lowerBound) && $0.age <= Int(ageRange.upperBound) })
    }
    
    private func fetchUsers() async {
        let blackUserCount = AuthViewModel.shared.blackUids.count
        let snapshot = try? await query
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 10 + blackUserCount)
            .getDocuments()
                
        guard let documents = snapshot?.documents else { return }
        
        let users = documents.compactMap { try? $0.data(as: User.self) }
            .filter { $0.id != Auth.auth().currentUser?.uid }
            .filter { !AuthViewModel.shared.blackUids.contains($0.id ?? "") }

        DispatchQueue.main.async {
            self.users.removeAll()
            self.queriedUsers.removeAll()
            self.users = users
            self.setQueriedUsers()
        }
        
    }
    
    func fetchMoreUsers(user: User) async {
        guard user.id == queriedUsers.last?.id else { return }
        guard let lastDoc = try? await COLLECTION_USERS.document(queriedUsers.last?.id ?? "").getDocument() else { return DocumentSnapshot.initialize() }
        
        let snapshot = try? await query
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 7)
            .start(afterDocument: lastDoc)
            .getDocuments()
        
        guard let documents = snapshot?.documents else { return }
        
        let users = documents.compactMap { try? $0.data(as: User.self) }
            .filter { $0.id != Auth.auth().currentUser?.uid }
            .filter { !AuthViewModel.shared.blackUids.contains($0.id ?? "") }
        
        DispatchQueue.main.async {
            self.users.removeAll()
            self.users = self.queriedUsers
            self.users += users
            self.setQueriedUsers()
        }
    }
    
    func storeFilterValue(gender: Gender?, region: Region?, ageRange: ClosedRange<Float>) {
                
        // UserDefaults에 적용한 filter값 저장 (-1 = 전체)
        defaults.setValue(gender?.rawValue ?? -1, forKey: DEFAULTS_MAIN_GENDER)
        defaults.setValue(region?.rawValue ?? -1, forKey: DEFAULTS_MAIN_REGION)
        defaults.setValue(ageRange.lowerBound, forKey: DEFAULTS_MAIN_AGERANGE_LOWERBOUND)
        defaults.setValue(ageRange.upperBound, forKey: DEFAULTS_MAIN_AGERANGE_UPPERBOUND)
        self.queriedUsers.removeAll()
        self.users.removeAll()
    }
}
