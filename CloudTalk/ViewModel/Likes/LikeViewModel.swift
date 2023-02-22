//
//  LikeViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/15.
//

import Foundation

class LikeViewModel: ObservableObject {
    
    @Published var receivedLikes = [LikeCard]()
    @Published var myLikes = [LikeCard]()
    
    init() {
        fetchReceivedLikes()
        fetchMyLikes()
    }
    
    private let currentUid = AuthViewModel.shared.currentUser?.id ?? ""
    
    private func fetchMyLikes() {
        self.myLikes.removeAll()
        COLLECTION_LIKECARDS
            .whereField(KEY_FROMID, isEqualTo: currentUid)
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 8)
            .getDocuments { snapshot, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                
                guard let likeCards = snapshot?.documents.compactMap({ try? $0.data(as: LikeCard.self) }) else { return }
                
                for (index, likeCard) in likeCards.enumerated() {
                    self.fetchUser(withUid: likeCard.toId) { user in
                        self.myLikes[index].user = user
                    }
                }
                
                self.myLikes.append(contentsOf: likeCards)
                print("myLikes: \(self.myLikes)")
            }
    }
    
    private func fetchReceivedLikes() {
        self.receivedLikes.removeAll()
        COLLECTION_LIKECARDS
            .whereField(KEY_TOID, isEqualTo: currentUid)
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 8)
            .getDocuments { snapshot, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                
                guard let likeCards = snapshot?.documents.compactMap({ try? $0.data(as: LikeCard.self) }) else { return }
                
                for (index, likeCard) in likeCards.enumerated() {
                    self.fetchUser(withUid: likeCard.fromId) { user in
                        self.receivedLikes[index].user = user
                    }
                }
                
                self.receivedLikes.append(contentsOf: likeCards)
            }
    }
    
    private func fetchUser(withUid uid: String, completion: @escaping (User) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else { return }
            completion(user)
        }
    }
}
