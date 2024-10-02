//
//  ChatList.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/09.
//

import SwiftUI

struct ChatList: View {
    @Binding var messages: [Message]
    let profileImageUrl: String
    let gender: Gender
    let partnerUser: AppUser
    
    @State var previousDate: Date = Date.distantPast
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(0 ..< messages.count, id: \.self) { index in
                MessageView(
                    message: self.messages[index],
                    profileImageUrl: profileImageUrl,
                    gender: gender,
                    partnerUser: partnerUser,
                    previousDate: index == 0 ? nil : self.messages[index - 1].date,
                    shouldShowTime: shouldShowTime(for: self.messages[index], in: messages)
                )
                    .id(self.messages[index].id)
                    .padding(.bottom, 18)
            }
        }
    }
    
    private func shouldShowTime(for message: Message, in messages: [Message]) -> Bool {
        guard let index = messages.firstIndex(of: message) else { return false }
        // 마지막 메시지이면 무조건 시간 표시
        if index == messages.count - 1 { return true }
        
        let currentMessageTime = message.timestamp.dateValue().formatYmd()
        let nextMessageTime = messages[index + 1].timestamp.dateValue().formatYmd()
        
        // 뒤의 메시지와 같은 유저야?
        let isSentBySameUser = message.fromId == messages[index + 1].fromId
        // 뒤의 메시지와 같은 시간에 보낸거야?
        let isSentAtSameTime = currentMessageTime == nextMessageTime
        
        if !isSentAtSameTime {
            return true
        } else if isSentAtSameTime && isSentBySameUser {
            return false
        } else if isSentAtSameTime && !isSentBySameUser {
            return true
        } else {
            print("안걸러진 케이스 있음")
            return true
        }
    }
    
    // 시간표시 로직
    // (뒤의 유저와) 같은 시간 + 다른 유저 = true
    // (뒤의 유저와) 같은 시간 + 같은 유저 = false
    // (뒤의 유저와) 다른 시간 = 무조건 true
}
