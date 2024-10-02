//
//  LikeViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/15.
//

import Foundation

@MainActor
class LikeViewModel: ObservableObject {
    
    @Published var receivedLikes = [LikeCard]()
    @Published var myLikes = [LikeCard]()
    
    init() {
        Task {
            await fetchLikes()
        }
        
    }
    
    private let currentUid = AuthViewModel.shared.currentUser?.id ?? ""
    
    func fetchLikes() async {
        await fetchReceivedLikes()
        await fetchMyLikes()
    }
    
    private func fetchMyLikes() async {
        self.myLikes.removeAll()
        let snapshot = try? await COLLECTION_LIKECARDS
            .whereField(KEY_FROMID, isEqualTo: currentUid)
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 8)
            .getDocuments()
        
        guard let likeCards = snapshot?.documents.compactMap({ try? $0.data(as: LikeCard.self) }) else { return }
        
        for (index, likeCard) in likeCards.enumerated() {
            self.fetchUser(withUid: likeCard.toId) { user in
                self.myLikes[index].user = user
            }
        }
        
        self.myLikes.append(contentsOf: likeCards)
    }
    
    private func fetchReceivedLikes() async {
        self.receivedLikes.removeAll()
        let snapshot = try? await COLLECTION_LIKECARDS
            .whereField(KEY_TOID, isEqualTo: currentUid)
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 8)
            .getDocuments()
        guard let likeCards = snapshot?.documents.compactMap({ try? $0.data(as: LikeCard.self) }) else { return }
        
        for (index, likeCard) in likeCards.enumerated() {
            self.fetchUser(withUid: likeCard.fromId) { user in
                self.receivedLikes[index].user = user
            }
        }
        
        self.receivedLikes.append(contentsOf: likeCards)
    }
    
    private func fetchUser(withUid uid: String, completion: @escaping (AppUser) -> Void) {
        COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: AppUser.self) else { return }
            completion(user)
        }
    }
}
