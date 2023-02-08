//
//  ChatCell.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/06.
//

import SwiftUI
import Kingfisher

struct ChatCell: View {
    
    @ObservedObject var viewModel: ChatCellViewModel
    
    private let chat: Chat
    
    init(chat: Chat) {
        self.chat = chat
        self.viewModel = ChatCellViewModel(chat: chat)
    }
    
    var body: some View {
        let chat = viewModel.chat
        if let user = viewModel.user {
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        makeProfileImage(user: user)
                            .padding(.trailing, 16)
                        VStack(spacing: 6) {
                            HStack(spacing: 0) {
                                Text(user.nickname)
                                    .font(.system(size: 16, weight: .bold))
                                Spacer()
                                Text(chat.timestamp.dateValue().timeAgoDisplay())
                                    .font(.system(size: 12, weight: .light))
                                    .foregroundColor(ColorManager.black200)
                            }
                            HStack(spacing: 0) {
                                Text(chat.lastMessage)
                                    .lineLimit(1)
                                    .font(.system(size: 15, weight: .light))
                                    .foregroundColor(ColorManager.black300)
                                    .frame(maxWidth: 232, alignment: .leading)
                                Spacer()
                                if chat.unReadMessageCount > 0 {
                                    makeBadge(num: chat.unReadMessageCount)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 20)
                HStack(spacing: 0) {
                    Spacer()
                        .frame(width: 96)
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(ColorManager.black50)
                }
            }
            .background(.white)
        }
        
        
    }
    
    @ViewBuilder private func makeBadge(num: Int) -> some View {
        Circle()
            .foregroundColor(ColorManager.backgroundColor)
            .frame(width: 20, height: 20)
            .overlay(
                Text(String(num))
                    .foregroundColor(.white)
                    .font(.system(size: 13))
            )
    }
    
    @ViewBuilder private func makeProfileImage(user: User) -> some View {
        Group {
            if !user.profileImageUrl.isEmpty {
                Color.clear
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        KFImage(URL(string: user.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(width: 62, height: 62)
                    .clipShape(Circle())
                    .contentShape(Circle())
            } else if user.gender == .man {
                Image("man")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 62, height: 62)
                    .clipShape(Circle())
                    .contentShape(Circle())
            } else {
                Image("woman")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 62, height: 62)
                    .clipShape(Circle())
                    .contentShape(Circle())
            }
        }
    }
}

struct ChatCell_Previews: PreviewProvider {
    static var previews: some View {
        ChatCell(chat: MOCK_CHAT)
    }
}
