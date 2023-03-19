//
//  DetailViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

@MainActor
class DetailViewModel: ObservableObject {
    
    let user: User
    @Published var isHeartPressed = false
    @Published var isChatting: Bool?
    @Published var isLoading = false
    @Published var chat: Chat?
    @Published var messageCount = 0 {
        didSet {
            self.blurRadius = CGFloat(10.0 - (Float(messageCount) / 30.0 * 10.0))
        }
    }
    @Published var blurRadius: CGFloat = 10.0
    
    init(user: User) {
        self.user = user
        Task {
            try? await Task.sleep(nanoseconds: 0_500_000_000)
            await fetchChattingInfo()
            await fetchMessagesCount()
        }
    }
    
    func fetchMessagesCount() async {
        guard let cid = chat?.id else { return }
        let snapshot = try? await COLLECTION_CHATS.document(cid).collection("messages").getDocuments()
        DispatchQueue.main.async {
            self.messageCount = snapshot?.documents.count ?? 0
            print(self.blurRadius)
        }
    }
    
    func fetchHeartPressedInfo() {
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
                    DispatchQueue.main.async {
                        self.isHeartPressed = true
                    }
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
                    
                    DispatchQueue.main.async {
                        self.isHeartPressed = false
                    }
                }
        } else {
            // TODO: Heart가 눌려있지 않았다면 LikeCard를 추가하기
            
            let data: [String: Any] = [
                KEY_FROMID: AuthViewModel.shared.currentUser?.id ?? "",
                KEY_TOID: user.id ?? "",
                KEY_TIMESTAMP: Timestamp(date: Date())
            ]
            
            COLLECTION_LIKECARDS.document().setData(data) { _ in
                DispatchQueue.main.async {
                    self.isHeartPressed = true
                }
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
    
    func ban() {
        COLLECTION_BANUSERS.document(user.id ?? "").setData([
            KEY_UID: user.id ?? ""
        ])
    }
}
