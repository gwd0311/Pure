//
//  PostViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/03.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

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
        loadPosts()
    }
    
    func loadPosts() {
        setFilter()
        setQuery()
        fetchPosts()
    }
    
    private func setFilter() {
        let gender = defaults.integer(forKey: DEFAULTS_POST_GENDER)
        let region = defaults.integer(forKey: DEFAULTS_POST_REGION)
        let lowerBound = defaults.float(forKey: DEFAULTS_POST_AGERANGE_LOWERBOUND)
        let upperBound = defaults.float(forKey: DEFAULTS_POST_AGERANGE_UPPERBOUND)
        
        if lowerBound == 0 && upperBound == 0 {
            return
        }
        
        self.gender = gender != -1 ? Gender(rawValue: gender) : nil
        self.region = region != -1 ? Region(rawValue: region) : nil
        self.ageRange = lowerBound...upperBound
        print(gender, region, ageRange)
    }
    
    private func setQuery() {
        
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
        self.queriedPosts = self.posts.filter({ $0.age >= Int(ageRange.lowerBound) && $0.age <= Int(ageRange.upperBound) })
    }
    
    private func fetchPosts() {
        query
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 7)
            .getDocuments { snapshot, err in
                if let err = err {
                    print("Error:: \(err)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                                
                let posts = documents.compactMap { try? $0.data(as: Post.self) }
                
                DispatchQueue.main.async {
                    self.posts.removeAll()
                    self.posts = posts
                    self.setQueriedPosts()
                }
        }
    }
    
    func fetchMorePosts(post: Post) async {
        guard post.id == posts.last?.id else { return }
        guard let lastDoc = try? await COLLECTION_POSTS.document(queriedPosts.last?.id ?? "").getDocument() else { return DocumentSnapshot.initialize() }
        
        let snapshot = try? await query
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 7)
            .start(afterDocument: lastDoc)
            .getDocuments()
        
        guard let documents = snapshot?.documents else { return }
        
        let posts = documents.compactMap { try? $0.data(as: Post.self) }
        
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
        self.queriedPosts.removeAll()
        self.posts.removeAll()
    }
}
