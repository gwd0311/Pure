//
//  ChatList.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/09.
//

import SwiftUI

struct ChatList: View {
    @Binding var messages: [Message]
    let partnerUser: User
    
    @State var previousDate: Date = Date.distantPast
    
    var body: some View {
        VStack {
            ForEach(0 ..< messages.count, id: \.self) { index in
                MessageView(
                    message: self.messages[index],
                    partnerUser: partnerUser,
                    previousDate: index == 0 ? nil : self.messages[index - 1].date
                )
                    .id(self.messages[index].id)
                    .padding(.bottom, 18)
            }
        }
    }
}
