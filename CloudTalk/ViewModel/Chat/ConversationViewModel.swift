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
    
    @Published var messages = [Message]()
    var shouldListen = true
    var lastMessageTime: Date?
    
    private var listener: ListenerRegistration?
    
    init(chat: Chat) {
        self.chat = chat
    }
    
    var currentUid: String {
        AuthViewModel.shared.currentUser?.id ?? ""
    }
    
    var partnerUid: String {
        if let uid = chat.uids.filter({ $0 != currentUid }).first {
            return uid
        } else {
            return ""
        }
    }
    
    var currentNickName: String {
        chat.userNickNames[currentUid] ?? "비활성화된닉네임"
    }
    
    var partnerNickName: String {
        chat.userNickNames[partnerUid] ?? "비활성화된닉네임"
    }
    
    var currentGender: Gender {
        chat.userGenders[currentUid] ?? .man
    }
    
    var partnerGender: Gender {
        chat.userGenders[partnerUid] ?? .man
    }
    
    var currentAge: Int {
        chat.userAges[currentUid] ?? 20
    }
    
    var partnerAge: Int {
        chat.userAges[partnerUid] ?? 20
    }
    
    var currentProfileImageUrl: String {
        chat.userProfileImages[currentUid] ?? ""
    }
    
    var partnerProfileImageUrl: String {
        chat.userProfileImages[partnerUid] ?? ""
    }
        
    func startListen() {
        if shouldListen {
            guard let cid = chat.id else { return }
            COLLECTION_CHATS.document(cid).collection("messages")
                .order(by: KEY_TIMESTAMP, descending: false)
                .limit(toLast: 50)
                .addSnapshotListener { snapShot, err in
                
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                    
                guard let changes = snapShot?.documentChanges.filter({ $0.type == .added }) else { return }
                    
                let messages = changes.compactMap({ try? $0.document.data(as: Message.self) })
                
                DispatchQueue.main.async {
                    self.messages.append(contentsOf: messages)
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
        
        let messageData: [String: Any] = [
            KEY_CID: cid,
            KEY_FROMID: currentUid,
            KEY_TOID: partnerUid,
            KEY_TEXT: messageText,
            KEY_TIMESTAMP: Timestamp(date: Date())
        ]
        
        COLLECTION_CHATS.document(cid).collection("messages").document().setData(messageData)

        COLLECTION_CHATS.document(cid).getDocument { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
            }
            
            guard let chat = try? snapshot?.data(as: Chat.self) else { return }
            
            self.setMessageData(
                chat: chat,
                currentUserId: self.currentUid,
                partnerUserId: self.partnerUid,
                messageText: messageText
            )
        }
    }
    
    private func setMessageData(chat: Chat, currentUserId: String, partnerUserId: String, messageText: String) {
        guard let cid = chat.id else { return }
        
        var unReadMessageCount = chat.unReadMessageCount
        unReadMessageCount[currentUserId] = (unReadMessageCount[currentUserId] ?? 0) + 1
        unReadMessageCount[partnerUserId] = (unReadMessageCount[partnerUserId] ?? 0)

        COLLECTION_CHATS.document(cid).updateData([
            KEY_LASTMESSAGE: messageText,
            KEY_TIMESTAMP: Timestamp(date: Date()),
            KEY_UNREADMESSAGECOUNT: unReadMessageCount
        ]) { _ in
            DispatchQueue.main.async {
                self.chat.unReadMessageCount = unReadMessageCount
            }
        }
    }
    
    func read() {
        guard let cid = chat.id else { return }
        guard let uid = chat.uids.filter({ $0 != AuthViewModel.shared.currentUser?.id }).first else { return }
        
        var unReadMessageCount = chat.unReadMessageCount
        unReadMessageCount[uid] = 0
        
        COLLECTION_CHATS.document(cid).updateData([
            KEY_UNREADMESSAGECOUNT: unReadMessageCount
        ]) { _ in
            DispatchQueue.main.async {
                self.chat.unReadMessageCount[uid] = 0
            }
        }
    }
    
}
