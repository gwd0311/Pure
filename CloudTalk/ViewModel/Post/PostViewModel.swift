//
//  PostViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/03.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

@MainActor
class PostViewModel: ObservableObject {
    
    @Published var posts = [Post]()
    @Published var queriedPosts = [Post]()
    
    // 필터 정보들
    @Published var gender: Gender?
    @Published var region: Region?
    @Published var ageRange: ClosedRange<Float> = 18...99
    
    let defaults = UserDefaults.standard
    var query: Query = COLLECTION_POSTS
    
    init() {
        Task {
            await loadPosts()
        }
    }
    
    func loadPosts() async {
        await setFilter()
        await setQuery()
        await fetchPosts()
    }
    
    private func setFilter() async {
        let gender = defaults.integer(forKey: DEFAULTS_POST_GENDER)
        let region = defaults.integer(forKey: DEFAULTS_POST_REGION)
        let lowerBound = defaults.float(forKey: DEFAULTS_POST_AGERANGE_LOWERBOUND)
        let upperBound = defaults.float(forKey: DEFAULTS_POST_AGERANGE_UPPERBOUND)
        
        if lowerBound == 0 && upperBound == 0 {
            return
        }
        
        DispatchQueue.main.async {
            self.gender = gender != -1 ? Gender(rawValue: gender) : nil
            self.region = region != -1 ? Region(rawValue: region) : nil
            self.ageRange = lowerBound...upperBound
        }
    }
    
    private func setQuery() async {
        
        if let gender = gender, let region = region {
            query = COLLECTION_POSTS
                .whereField(KEY_GENDER, isEqualTo: gender.rawValue)
                .whereField(KEY_REGION, isEqualTo: region.rawValue)
        } else if let gender = gender, region == nil {
            query = COLLECTION_POSTS
                .whereField(KEY_GENDER, isEqualTo: gender.rawValue)
        } else if let region = region, gender == nil {
            query = COLLECTION_POSTS
                .whereField(KEY_REGION, isEqualTo: region.rawValue)
        } else {
            query = COLLECTION_POSTS
        }
        
    }
    
    private func setQueriedPosts() {
        let lowerBound = Int(ageRange.lowerBound)
        let upperBound = Int(ageRange.upperBound)
        
        if lowerBound == 18 && upperBound == 99 {
            self.queriedPosts = self.posts.filter({ $0.age >= -1 && $0.age <= upperBound })
        } else {
            self.queriedPosts = self.posts.filter({ $0.age >= lowerBound && $0.age <= upperBound })
        }
    }
    
    private func fetchPosts() async {
            
        let snapshot = try? await query
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 10 + AuthViewModel.shared.blackUids.count)
            .getDocuments()
                    
        guard let documents = snapshot?.documents else { return }
                            
        let posts = documents.compactMap { try? $0.data(as: Post.self) }
            .filter({ !AuthViewModel.shared.blackUids.contains($0.uid) })
        
        var newPosts = [Post]()
        
        for post in posts {
            if let user = try? await fetchUser(post: post) {
                var newPost = post
                newPost.user = user
                newPosts.append(newPost)
            }
        }
        
        DispatchQueue.main.async {
            self.posts = newPosts
            self.setQueriedPosts()
        }
    }

    
    func fetchMorePosts(post: Post) async {
        guard post.id == posts.last?.id else { return }
        guard let lastDoc = try? await COLLECTION_POSTS.document(queriedPosts.last?.id ?? "").getDocument() else { return DocumentSnapshot.initialize() }
        
        let snapshot = try? await query
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 10 + AuthViewModel.shared.blackUids.count)
            .start(afterDocument: lastDoc)
            .getDocuments()
        
        guard let documents = snapshot?.documents else { return }
        
        let posts = documents.compactMap { try? $0.data(as: Post.self) }
            .filter({ !AuthViewModel.shared.blackUids.contains($0.uid) })
        
        DispatchQueue.main.async {
            self.posts.removeAll()
            self.posts = self.queriedPosts
            self.posts += posts
            self.setQueriedPosts()
        }
    }
    
    func storeFilterValue(gender: Gender?, region: Region?, ageRange: ClosedRange<Float>) {
                
        // UserDefaults에 적용한 filter값 저장 (-1 = 전체)
        defaults.setValue(gender?.rawValue ?? -1, forKey: DEFAULTS_POST_GENDER)
        defaults.setValue(region?.rawValue ?? -1, forKey: DEFAULTS_POST_REGION)
        defaults.setValue(ageRange.lowerBound, forKey: DEFAULTS_POST_AGERANGE_LOWERBOUND)
        defaults.setValue(ageRange.upperBound, forKey: DEFAULTS_POST_AGERANGE_UPPERBOUND)
        
        DispatchQueue.main.async {
            self.queriedPosts.removeAll()
            self.posts.removeAll()
        }
    }
    
    func fetchUser(post: Post) async throws -> User {
        let user = try? await COLLECTION_USERS.document(post.uid).getDocument(as: User.self)
        return user ?? MOCK_USER
    }
}
