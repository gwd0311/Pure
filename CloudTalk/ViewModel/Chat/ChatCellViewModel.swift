//
//  ChatCellViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import Foundation

class ChatCellViewModel: ObservableObject {
    
    let chat: Chat
    @Published var user: User?
    
    init(chat: Chat) {
        self.chat = chat
        self.fetchUser()
    }
    
    func fetchUser() {
        guard let uid = chat.uids.filter({ $0 != AuthViewModel.shared.currentUser?.id }).first else { return }
        
        COLLECTION_USERS.document(uid).getDocument { snapShot, err in
            
            if let err = err {
                print(err.localizedDescription)
            }
            
            guard let user = try? snapShot?.data(as: User.self) else { return }
            
            self.user = user
        }
    }
    
}
