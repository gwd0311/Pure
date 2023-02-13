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
    let previousDate: Date?
    let shouldShowTime: Bool
    
    init(message: Message, partnerUser: User, previousDate: Date? = nil, shouldShowTime: Bool) {
        self.message = message
        self.partnerUser = partnerUser
        self.previousDate = previousDate
        self.shouldShowTime = shouldShowTime
    }
    
    var time: String {
        message.timestamp.dateValue().formatHm()
    }
    
    var shouldShowDate: Bool {
        previousDate == nil || Calendar.current.compare(message.date, to: previousDate!, toGranularity: .day) != .orderedSame
    }
    
    var currentUid: String {
        return AuthViewModel.shared.userSession?.uid ?? ""
    }
    
    var isFromCurrentUser: Bool {
        return message.fromId == currentUid
    }
    
}
