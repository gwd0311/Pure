//
//  MessageViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/08.
//

import Foundation

class MessageViewModel: ObservableObject {
    
    let message: Message
    let partnerUser: User
    
    init(_ message: Message, partnerUser: User) {
        self.message = message
        self.partnerUser = partnerUser
    }
    
    var currentUid: String {
        return AuthViewModel.shared.userSession?.uid ?? ""
    }
    
    var isFromCurrentUser: Bool {
        return message.fromId == currentUid
    }
    
}
