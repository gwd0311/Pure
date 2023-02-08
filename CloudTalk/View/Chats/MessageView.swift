//
//  MessageView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/08.
//

import SwiftUI

struct MessageView: View {
    
    let viewModel: MessageViewModel
    let message: Message
    let partnerUser: User
    
    init(message: Message, partnerUser: User) {
        self.message = message
        self.partnerUser = partnerUser
        self.viewModel = MessageViewModel(message, partnerUser: partnerUser)
    }
    
    var body: some View {
        if viewModel.isFromCurrentUser {
            HStack(spacing: 0) {
                Spacer()
                VStack(spacing: 0) {
                    Spacer()
                    Text(viewModel.message.timestamp.dateValue().formatHm())
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(ColorManager.black250)
                }
                .padding(.trailing, 4)
                Text(viewModel.message.text)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(ColorManager.blue)
                    .cornerRadius(15, corners: [.topLeft, .topRight, .bottomLeft])
            }
            .padding(.horizontal, 18)
        } else {
            HStack(spacing: 0) {
                VStack(spacing: 0) {
                    Spacer()
                    ProfileImageView(user: viewModel.partnerUser, type: .circle, width: 32, height: 32)
                        .padding(.trailing, 8)
                }
                Text(viewModel.message.text)
                    .font(.system(size: 16, weight: .light))
                    .foregroundColor(ColorManager.black600)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(ColorManager.black50)
                    .cornerRadius(15, corners: [.topLeft, .topRight, .bottomRight])
                    .padding(.trailing, 4)
                VStack(spacing: 0) {
                    Spacer()
                    Text(viewModel.message.timestamp.dateValue().formatHm())
                        .font(.system(size: 11, weight: .light))
                        .foregroundColor(ColorManager.black250)
                        .padding(.bottom, 4)
                }
                Spacer()
            }
            .padding(.horizontal, 18)
        }
    }
}

//struct MessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageView(message: MOCK_MESSAGE, partnerUser: MOCK_USER, proxy: )
//    }
//}
