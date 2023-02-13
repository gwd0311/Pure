//
//  SendMessageViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import Foundation
import Firebase

class SendMessageViewModel: ObservableObject {
    
    
    let user: User // DetailView에서 선택한 유저, toID에 적합
    
    init(user: User) {
        self.user = user
    }
    
    func setChats(text: String) async {
        guard let fromId = AuthViewModel.shared.currentUser?.id else { return }
        guard let toId = user.id else { return }
        
        guard let currentUser = AuthViewModel.shared.currentUser else { return }
        let partnerUser = user
        
        let data: [String: Any] = [
            KEY_UIDS: [fromId, toId],
            KEY_USER_NICKNAMES: [fromId: currentUser.nickname, toId: partnerUser.nickname],
            KEY_USER_PROFILE_IMAGES: [fromId: currentUser.profileImageUrl, toId: partnerUser.profileImageUrl],
            KEY_USER_GENDERS: [fromId: currentUser.gender.rawValue, toId: partnerUser.gender.rawValue],
            KEY_LASTMESSAGE: text,
            KEY_UNREADMESSAGECOUNT: [fromId: 1, toId: 0],
            KEY_TIMESTAMP: Timestamp(date: Date())
        ]
        
        let ref = COLLECTION_CHATS.document()
        let docId = ref.documentID
        try? await ref.setData(data)
        await setMessages(text: text, docId: docId)
    }
    
    private func setMessages(text: String, docId: String) async {
        guard let fromId = AuthViewModel.shared.currentUser?.id else { return }
        guard let toId = user.id else { return }
        
        let data: [String: Any] = [
            KEY_CID: docId,
            KEY_FROMID: fromId,
            KEY_TOID: toId,
            KEY_TEXT: text,
            KEY_TIMESTAMP: Timestamp(date: Date())
        ]
        try? await COLLECTION_CHATS.document(docId).collection("messages").document().setData(data)
    }
}
