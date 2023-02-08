//
//  DetailViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import Foundation
import FirebaseFirestoreSwift

class DetailViewModel: ObservableObject {
    
    let user: User
    @Published var isHeartPressed = false
    @Published var isChatting: Bool?
    @Published var chat: Chat?
    
    init(user: User) {
        self.user = user
    }
    
    private func fetchHeartPressedInfo() {
        // TODO: - 하트 좋아요 눌린 상태인지 아닌지 체크해서 가져와야함
        // isHeartPressed = true
        
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
