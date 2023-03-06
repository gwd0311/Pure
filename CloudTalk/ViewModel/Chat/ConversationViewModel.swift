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
    
    // MARK: - 메시지 보내기
    func sendMessage(_ messageText: String, isPushOn: Bool) {
        guard let cid = chat.id else { return }
        
        let messageData: [String: Any] = [
            KEY_CID: cid,
            KEY_FROMID: currentUid,
            KEY_TOID: partnerUid,
            KEY_TEXT: messageText,
            KEY_TIMESTAMP: Timestamp(date: Date())
        ]
        
        COLLECTION_CHATS.document(cid).collection("messages").document().setData(messageData) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            COLLECTION_USERS.document(self.partnerUid).getDocument { snapshot, err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                
                guard let partnerUser = try? snapshot?.data(as: User.self) else { return }
                
                if partnerUser.isPushOn {
                    self.sendPushMessage(chatPartnerId: self.partnerUid)
                }
            }
                
        }

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
    
    // MARK: - 안읽은 메시지 수 표시하기
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
    
    // MARK: - 안읽은 메시지 수 0으로 초기화하기
    func read() {
        guard let cid = chat.id else { return }
        guard let uid = chat.uids.filter({ $0 != AuthViewModel.shared.currentUser?.id }).first else { return }
        
        COLLECTION_CHATS.document(cid).getDocument { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            guard let chat = try? snapshot?.data(as: Chat.self) else { return }
            
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
    
    // MARK: - 푸쉬알림 보내기
    private func sendPushMessage(chatPartnerId: String) {
        // Firebase API를 활용해서 쉽게 다른기기에 푸쉬알림보내기
        
        // URL 요청 포맷으로 변환하기
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else {
            return
        }
        
        
        COLLECTION_TOKENS.document(chatPartnerId).getDocument { snapshotData, error in
            if let error = error {
                print("DEBUG: 푸쉬알림 토큰을 가져오는 중 오류 발생 \(error)")
                return
            }
            
            guard let data = try? snapshotData?.data(as: Token.self) else {
                print("Token 변환중 오류발생")
                return
            }
            
            self.requestPushAPI(token: data.token, url: url)
        }

    }
    
    private func requestPushAPI(token: String, url: URL) {
        let json: [String: Any] = [
            "to": token,
            "notification": [
                "title": "메시지 알림",
                "body": "메시지가 도착했습니다."
            ],
            "data": [
                // 보낼 데이터
                // 빈 상태로 두지 말아야한다. 아니면 차라리 블록을 지우는게 나음
                "user_name": "test"
            ]
        ]
        
        let serverKey = "AAAAw4Ue2XQ:APA91bFfgm8ucUHoatTTFy4rPgmlFFfutdpLpN45AiqyEbn-NmBxWL9YmiPuKu9kWHiftokuQ0o9KB6ylvJFlsTvaHaiZMq0icy8TfVynyYLs8bdnwkflapirz8bVSpN4IvorFCUALPq"
        
        // URL 요청
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // Dict 자료형에서 Json으로 변환
        request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted])
        
        // Content type과 Authorization 설정
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // Authorization key는 내 서버키다.
        request.setValue("key=\(serverKey)", forHTTPHeaderField: "Authorization")
        
        // URLSession으로 요청 보내기
        let session = URLSession(configuration: .default)
        
        session.dataTask(with: request) { _, _, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
        }
        .resume()
    }
}
