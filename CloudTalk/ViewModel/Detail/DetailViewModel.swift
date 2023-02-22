//
//  DetailViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class DetailViewModel: ObservableObject {
    
    let user: User
    @Published var isHeartPressed = false
    @Published var isChatting: Bool?
    @Published var isLoading = false
    @Published var chat: Chat?
    
    init(user: User) {
        self.user = user
        fetchHeartPressedInfo()
    }
    
    private func fetchHeartPressedInfo() {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        COLLECTION_LIKECARDS
            .whereField(KEY_FROMID, isEqualTo: uid)
            .whereField(KEY_TOID, isEqualTo: user.id ?? "")
            .getDocuments { snapshot, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                
                guard let likeCards = snapshot?.documents.compactMap({ try? $0.data(as: LikeCard.self) }) else { return }
                
                if !likeCards.isEmpty {
                    self.isHeartPressed = true
                }
            }
    }
    
    func pressLikeButton() {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        if isHeartPressed {
            // TODO: Heart가 눌려있었다면 LikeCard를 제거하기 (성공 시 isHeartPressed = false)
            COLLECTION_LIKECARDS
                .whereField(KEY_FROMID, isEqualTo: uid)
                .whereField(KEY_TOID, isEqualTo: user.id ?? "")
                .getDocuments { snapshot, err in
                    if let err = err {
                        print(err.localizedDescription)
                        return
                    }
                    
                    snapshot?.documents.forEach({ snapshot in
                        snapshot.reference.delete()
                    })
                    
                    self.isHeartPressed = false
                }
        } else {
            // TODO: Heart가 눌려있지 않았다면 LikeCard를 추가하기
            
            let data: [String: Any] = [
                KEY_FROMID: AuthViewModel.shared.currentUser?.id ?? "",
                KEY_TOID: user.id ?? "",
                KEY_TIMESTAMP: Timestamp(date: Date())
            ]
            
            COLLECTION_LIKECARDS.document().setData(data) { _ in
                self.isHeartPressed = true
            }
            
        }
    }
    
    func fetchChattingInfo() async {
        guard let fromId = AuthViewModel.shared.currentUser?.id else { return }
        guard let toId = user.id else { return }
        guard let snapShot = try? await COLLECTION_CHATS.whereField(KEY_UIDS, in: [[fromId, toId], [toId, fromId]]).getDocuments() else {
            DispatchQueue.main.async {
                self.isChatting = false
            }
            return
        }
        DispatchQueue.main.async {
            if snapShot.documents.count > 0 {
                self.isChatting = true
                guard let chat = snapShot.documents.compactMap({ try? $0.data(as: Chat.self) }).first else { return }
                
                self.chat = chat
            } else {
                self.isChatting = false
            }
        }
    }
    
}
