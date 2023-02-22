//
//  ChatCellViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/13.
//

import Foundation

class ChatCellViewModel: ObservableObject {
    
    let chat: Chat
    @Published var user: User?
    
    init(chat: Chat) {
        self.chat = chat
        Task {
            try? await Task.sleep(nanoseconds: 0_500_000_000)
            self.fetchUser()
        }
    }
    
    private func fetchUser() {
        guard let uid = chat.uids.filter({ $0 != AuthViewModel.shared.currentUser?.id }).first else { return }
        COLLECTION_USERS.document(uid).getDocument { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
            }
            
            guard let user = try? snapshot?.data(as: User.self) else { return }
            
            self.user = user
        }
    }
    
}
