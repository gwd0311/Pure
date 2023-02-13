//
//  ChatCell.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/06.
//

import SwiftUI
import Kingfisher

struct ChatCell: View {
    
    let chat: Chat
    
    var body: some View {
        if let uid = chat.uids.filter({ $0 != AuthViewModel.shared.currentUser?.id }).first {
            let profileImageUrl = chat.userProfileImages[uid] ?? ""
            let gender = chat.userGenders[uid] ?? .woman
            let nickName = chat.userNickNames[uid] ?? ""
            let unReadMessageCount = chat.unReadMessageCount[uid] ?? 0
            
            VStack(spacing: 0) {
                VStack(spacing: 0) {
                    HStack(spacing: 0) {
                        makeProfileImage(profileImageUrl: profileImageUrl, gender: gender)
                            .padding(.trailing, 16)
                        VStack(spacing: 6) {
                            HStack(spacing: 0) {
                                Text(nickName)
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
                                if unReadMessageCount > 0 {
                                    makeBadge(num: unReadMessageCount)
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
    
    @ViewBuilder private func makeProfileImage(profileImageUrl: String, gender: Gender) -> some View {
        CustomNavigationLink {
            DetailView(viewModel: DetailViewModel(user: <#T##User#>))
        } label: {
            Group {
                if !profileImageUrl.isEmpty {
                    Color.clear
                        .aspectRatio(contentMode: .fill)
                        .overlay(
                            KFImage(URL(string: profileImageUrl))
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(width: 62, height: 62)
                        .clipShape(Circle())
                        .contentShape(Circle())
                } else if gender == .man {
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
}

//struct ChatCell_Previews: PreviewProvider {
//    static var previews: some View {
//        ChatCell(chat: MOCK_CHAT)
//    }
//}
