//
//  ConversationViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/08.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class ConversationViewModel: ObservableObject {
    
    let chat: Chat
    
    @Published var partnerUser: User?
    @Published var currentUser: User? = AuthViewModel.shared.currentUser
    @Published var messages = [Message]()
    @Published var scrollCount = 0
    
    init(chat: Chat) {
        self.chat = chat
        self.fetchMessages()
        self.fetchPartenerUser()
    }
    
    func fetchMessages() {
        guard let cid = chat.id else { return }
        COLLECTION_CHATS.document(cid).collection("messages")
            .order(by: KEY_TIMESTAMP, descending: false)
            .addSnapshotListener { snapShot, err in
            
            if let err = err {
                print(err.localizedDescription)
            }
            
            guard let changes = snapShot?.documentChanges.filter({ $0.type == .added }) else { return }
                
            let messages = changes.compactMap({ try? $0.document.data(as: Message.self) })
            
            self.messages.append(contentsOf: messages)
        }
    }
    
    func sendMessage(_ messageText: String) {
        guard let cid = chat.id else { return }

        let messageData: [String: Any] = [
            KEY_FROMID: currentUser?.id ?? "",
            KEY_TOID: partnerUser?.id ?? "",
            KEY_ISREAD: false,
            KEY_TEXT: messageText,
            KEY_TIMESTAMP: Timestamp(date: Date())
        ]
        
        COLLECTION_CHATS.document(cid).collection("messages").document().setData(messageData) { _ in
            DispatchQueue.main.async {
                self.scrollCount += 1
            }
        }
        COLLECTION_CHATS.document(cid).updateData([
            KEY_LASTMESSAGE: messageText,
            KEY_TIMESTAMP: Timestamp(date: Date())
        ])
    }
    
    func fetchPartenerUser() {
        guard let cid = chat.id else { return }
        
        COLLECTION_CHATS.document(cid).getDocument { snapShot, err in
            
            if let err = err {
                print(err.localizedDescription)
            }
            
            guard let chat = try? snapShot?.data(as: Chat.self) else { return }
            
            guard let partnerUid = chat.uids.filter({ $0 != self.currentUser?.id }).first else { return }
            
            COLLECTION_USERS.document(partnerUid).getDocument { snapShot, err in
                
                if let err = err {
                    print(err.localizedDescription)
                }
                
                guard let partnerUser = try? snapShot?.data(as: User.self) else { return }
                
                self.partnerUser = partnerUser
            }
        }
    }
}
