//
//  ChatCellViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import Foundation

class ChatCellViewModel: ObservableObject {
    
    let chat: Chat
    var user: User?
    
    init(chat: Chat) {
        self.chat = chat
        Task {
            await fetchUser()
        }
    }
    
    private func fetchUser() async {
        guard let uid = chat.uids.filter({ $0 != AuthViewModel.shared.currentUser?.id }).first else { return }
        
        let snapShot = try? await COLLECTION_USERS.document(uid).getDocument()
        guard let user = try? snapShot?.data(as: User.self) else { return }
        self.user = user
    }
    
}
