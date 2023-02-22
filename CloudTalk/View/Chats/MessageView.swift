//
//  MessageView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/08.
//

import SwiftUI

struct MessageView: View {
    
    let viewModel: MessageViewModel
    
    init(
        message: Message,
        profileImageUrl: String,
        gender: Gender,
        previousDate: Date? = nil,
        shouldShowTime: Bool
    ) {
        self.viewModel = MessageViewModel(
            message: message,
            profileImageUrl: profileImageUrl,
            gender: gender,
            previousDate: previousDate,
            shouldShowTime: shouldShowTime
        )
    }
    
    var body: some View {
        
        let date = viewModel.message.date.ymdWithDay
        
        if viewModel.isFromCurrentUser {
            VStack {
                makeDate(dateString: date)
                HStack(spacing: 0) {
                    Spacer()
                    makeTime()
                        .padding(.trailing, 4)
                        .padding(.bottom, 1)
                    makeBubble(foregroundColor: .white, backgroundColor: ColorManager.blue, corners: [.topLeft, .topRight, .bottomLeft])
                }
                .padding(.horizontal, 18)
            }
        } else {
            VStack {
                makeDate(dateString: date)
                HStack(spacing: 0) {
                    VStack(spacing: 0) {
                        Spacer()
                        ProfileImageView(
                            profileImageUrl: self.viewModel.profileImageUrl,
                            gender: self.viewModel.gender,
                            type: .circle,
                            width: 32,
                            height: 32
                        )
                            .padding(.trailing, 8)
                    }
                    makeBubble(foregroundColor: ColorManager.black600, backgroundColor: ColorManager.black50, corners: [.topLeft, .topRight, .bottomRight])
                        .padding(.trailing, 4)
                    makeTime()
                        .padding(.bottom, 4)
                    Spacer()
                }
                .padding(.horizontal, 18)
            }
        }
    }
    
    @ViewBuilder private func makeBubble(foregroundColor: Color, backgroundColor: Color, corners: UIRectCorner) -> some View {
        Text(viewModel.message.text)
            .font(.system(size: 16, weight: .light))
            .foregroundColor(foregroundColor)
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .cornerRadius(15, corners: corners)
    }
    
    @ViewBuilder private func makeDate(dateString: String) -> some View {
        if viewModel.shouldShowDate {
            Text(dateString)
                .font(.system(size: 13, weight: .light))
                .foregroundColor(ColorManager.black250)
        }
    }
    
    @ViewBuilder private func makeTime() -> some View {
        if viewModel.shouldShowTime {
            VStack(alignment: viewModel.isFromCurrentUser ? .trailing : .leading, spacing: 0) {
                Spacer()
                Text(viewModel.time)
                    .font(.system(size: 11, weight: .light))
                    .foregroundColor(ColorManager.black250)
            }
        }
    }
}

//struct MessageView_Previews: PreviewProvider {
//    static var previews: some View {
//        MessageView(message: MOCK_MESSAGE, partnerUser: MOCK_USER, proxy: )
//    }
//}
