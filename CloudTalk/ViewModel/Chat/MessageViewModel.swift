//
//  MessageViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/08.
//

import Foundation

class MessageViewModel: ObservableObject {
    
    let message: Message
    let profileImageUrl: String
    let gender: Gender
    let previousDate: Date?
    let shouldShowTime: Bool
    
    init(message: Message, profileImageUrl: String, gender: Gender, previousDate: Date? = nil, shouldShowTime: Bool) {
        self.message = message
        self.profileImageUrl = profileImageUrl
        self.gender = gender
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
