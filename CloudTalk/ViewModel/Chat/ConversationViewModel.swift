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
    
    var chat: Chat
    
    @Published var partnerUser: User?
    @Published var currentUser: User? = AuthViewModel.shared.currentUser
    @Published var messages = [Message]()
    @Published var scrollCount = 0
    var shouldListen = true
    
    init(chat: Chat) {
        self.chat = chat
        self.fetchPartenerUser()
    }
    
    private var listener: ListenerRegistration?
        
    func startListen() {
        if shouldListen {
            guard let cid = chat.id else { return }
            COLLECTION_CHATS.document(cid).collection("messages")
                .order(by: KEY_TIMESTAMP, descending: false)
                .addSnapshotListener { snapShot, err in
                
                if let err = err {
                    print(err.localizedDescription)
                }
                    
                guard let changes = snapShot?.documentChanges.filter({ $0.type == .added }) else { return }
                    
                let messages = changes.compactMap({ try? $0.document.data(as: Message.self) })
                
                DispatchQueue.main.async {
                    self.messages.append(contentsOf: messages)
                    self.scrollCount += 1
                }
                
            }
            shouldListen = false
        }
    }
    
    func stopListen() {
        listener?.remove()
    }
    
    func initializeCount(onEnd: @escaping () -> Void) {
        guard let cid = chat.id else { return }
        print("실행되었음")
        guard let uid = chat.uids.filter({ $0 != AuthViewModel.shared.currentUser?.id }).first else { return }
        COLLECTION_CHATS.document(cid).updateData([
            KEY_UNREADMESSAGECOUNT: [uid: 0]
        ]) { _ in
            onEnd()
        }
    }
    
    func sendMessage(_ messageText: String) {
        guard let cid = chat.id else { return }
        guard let currentUserId = currentUser?.id else { return }
        guard let partnerUserId = partnerUser?.id else { return }
        
        let messageData: [String: Any] = [
            KEY_CID: cid,
            KEY_FROMID: currentUserId,
            KEY_TOID: partnerUserId,
            KEY_TEXT: messageText,
            KEY_TIMESTAMP: Timestamp(date: Date())
        ]
        
        var unReadMessageCount = chat.unReadMessageCount
        unReadMessageCount[currentUserId] = (unReadMessageCount[currentUserId] ?? 0) + 1
        unReadMessageCount[partnerUserId] = (unReadMessageCount[partnerUserId] ?? 0)

        COLLECTION_CHATS.document(cid).collection("messages").document().setData(messageData)
        COLLECTION_CHATS.document(cid).updateData([
            KEY_LASTMESSAGE: messageText,
            KEY_TIMESTAMP: Timestamp(date: Date()),
            KEY_UNREADMESSAGECOUNT: unReadMessageCount
        ]) { _ in
            self.chat.unReadMessageCount = unReadMessageCount
        }
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
