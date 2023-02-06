//
//  SendMessageViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import Foundation

class SendMessageViewModel: ObservableObject {
    
    
    let user: User // DetailView에서 선택한 유저, toID에 적합
    
    init(user: User) {
        self.user = user
    }
    
    func sendNewMessage(text: String) async {
        
        // TODO: - COLLECTION_CHATS에 채팅목록 세팅하기
        // TODO: - COLLECTION_CHATS - collection("messages")에 메시지 목록 세팅하기
        
        guard let fromId = AuthViewModel.shared.currentUser?.id else { return }
        guard let toId = user.id else { return }
        let data: [String: Any] = [
            :
        ]
        try? await COLLECTION_CHATS.document().setData(data)
    }
    
}
