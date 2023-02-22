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
    @ObservedObject var viewModel: ChatCellViewModel
    @State private var offset: CGFloat = 0
    @State private var isSwiped = false
    let onDelete: (Chat) -> Void
    
    init(chat: Chat, onDelete: @escaping (Chat) -> Void) {
        self.chat = chat
        self.viewModel = ChatCellViewModel(chat: chat)
        self.onDelete = onDelete
    }
    
    var body: some View {
        if let uid = chat.uids.filter({ $0 != AuthViewModel.shared.currentUser?.id }).first {
            let profileImageUrl = chat.userProfileImages[uid] ?? ""
            let gender = chat.userGenders[uid] ?? .woman
            let nickName = chat.userNickNames[uid] ?? ""
            let unReadMessageCount = chat.unReadMessageCount[uid] ?? 0
            
            ZStack {
                makeDeleteButton()
                makeCell(
                    nickName: nickName,
                    gender: gender,
                    profileImageUrl: profileImageUrl,
                    unReadMessageCount: unReadMessageCount
                )
            }
        } else {
            let profileImageUrl = ""
            let gender = Gender.man
            let nickName = "삭제된닉네임"
            let unReadMessageCount = 0
            ZStack {
                makeDeleteButton()
                makeCell(
                    nickName: nickName,
                    gender: gender,
                    profileImageUrl: profileImageUrl,
                    unReadMessageCount: unReadMessageCount
                )
            }
        }
    }
    
    @ViewBuilder private func makeCell(nickName: String, gender: Gender, profileImageUrl: String, unReadMessageCount: Int) -> some View {
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
                            Text(chat.uids.count == 2 ? chat.lastMessage : "상대방이 대화를 종료했습니다.")
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
        .background(.white)
        .offset(x: self.offset)
        .gesture(DragGesture().onChanged(onChanged(value:)).onEnded(onEnd(value:)))
    }
    
    @ViewBuilder private func makeDeleteButton() -> some View {
        HStack {
            Spacer()
            
            Button(action: {
                withAnimation(.easeIn){ onDelete(chat) }
            }) {
                Image(systemName: "trash")
                    .font(.title)
                    .foregroundColor(.white)
                    .frame(width: 90, height: 103)
            }
        }
        .background(LinearGradient(gradient: .init(colors: [ColorManager.redLight, ColorManager.red]), startPoint: .leading, endPoint: .trailing))
    }
    
    private func onChanged(value: DragGesture.Value) {
        if value.translation.width < 0 {
            if isSwiped {
                offset = value.translation.width - 90
            } else {
                offset = value.translation.width
            }
        }
    }
    
    private func onEnd(value: DragGesture.Value) {
        withAnimation(.easeOut) {
            if value.translation.width < 0 {
                if -offset > 50 {
                    isSwiped = true
                    offset = -90
                } else {
                    isSwiped = false
                    offset = 0
                }
            } else {
                isSwiped = false
                offset = 0
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
            // TODO: user 만들어서 넣어줘야함
            if let user = viewModel.user {
                DetailView(viewModel: DetailViewModel(user: user))
            }
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

struct ChatCell_Previews: PreviewProvider {
    static var previews: some View {
        ChatCell(chat: MOCK_CHAT, onDelete: { _ in })
    }
}
