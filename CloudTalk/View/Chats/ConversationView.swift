//
//  ConversationView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import SwiftUI

struct ConversationView: View {
    
    @ObservedObject private var viewModel: ConversationViewModel
    @State private var text = ""
    @State private var isLoading = false
    @State private var isEditing = false
    @State private var showDialog = false
    @Environment(\.dismiss) var dismiss
    
    private let chat: Chat
    
    init(chat: Chat) {
        self.chat = chat
        self.viewModel = ConversationViewModel(chat: chat)
    }
    
    var body: some View {
        if let currentUser = viewModel.currentUser,
           let partnerUser = viewModel.partnerUser {
            ScrollViewReader { proxy in
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(spacing: 0) {
                            makeProfiles(currentUser: currentUser, partnerUser: partnerUser)
                                .padding(.top, 16)
                                .padding(.bottom, 18)
                            ChatList(messages: $viewModel.messages, partnerUser: partnerUser)
                            HStack { Spacer() }.id("Scroll")
                        }
                        .onReceive(viewModel.$scrollCount) { _ in
                            proxy.scrollTo("Scroll", anchor: .bottom)
                        }
                    }
                    makeMessageInput(proxy: proxy)
                }
                .onAppear {
                    self.viewModel.startListen()
                }
                .onDisappear(perform: viewModel.stopListen)
                .resignKeyboard()
                .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification), perform: { _ in
                    withAnimation {
                        proxy.scrollTo("Scroll", anchor: .bottom)
                    }
                })
                .customNavigationTitle(partnerUser.nickname)
                .customNavBarItems(trailing: trailingItems)
            }
            .confirmationDialog("Select", isPresented: $showDialog) {
                Button("차단하기") {
                    
                }
                Button("신고하기") {
                    
                }
            }
        } else {
            VStack(spacing: 0) {
                Image("cloud_sad")
                    .padding(.bottom, 18)
                Text("데이터를 가져오지 못했습니다 ㅠㅠ")
                    .foregroundColor(ColorManager.black500)
                    .font(.system(size: 16, weight: .bold))
            }
        }
    }
    
    // MARK: - 하단 채팅 입력창
    @ViewBuilder private func makeMessageInput(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(ColorManager.black50)
                .frame(height: 1)
            HStack(spacing: 0) {
                MultilineTextField("새 메시지 입력", text: $text)
                Spacer()
                Button {
                    viewModel.sendMessage(text)
                    self.text = ""
                } label: {
                    if text.isEmpty {
                        Image("sendBtn_off")
                    } else {
                        Image("sendBtn_on")
                    }
                }
                .disabled(text.isEmpty)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
    }
    
    //MARK: - 상단 프로필 정보
    @ViewBuilder private func makeProfiles(currentUser: User, partnerUser: User) -> some View {
        VStack(spacing: 12) {
            VStack(spacing: 0) {
                ZStack {
                    HStack(spacing: 0) {
                        Spacer()
                        ProfileImageView(user: currentUser, type: .circle)
                    }
                    HStack(spacing: 0) {
                        ProfileImageView(user: partnerUser, type: .circle)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 2)
                            )
                        Spacer()
                    }
                }
            }
            .frame(width: 86, height: 46)
            HStack(spacing: 4) {
                Text(partnerUser.nickname)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(ColorManager.blue)
                Text("\(partnerUser.age)세 \(partnerUser.gender.title)")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(ColorManager.black200)
            }
        }
    }
    
    // MARK: - 우측 상단 아이템들
    private var trailingItems: some View {
        HStack(spacing: 16) {
            Button {
                showDialog.toggle()
            } label: {
                Image("more")
            }
            Button {
                dismiss()
            } label: {
                Image("out")
            }
        }
    }
}

struct ConversationView_Previews: PreviewProvider {
    static var previews: some View {
        ConversationView(chat: MOCK_CHAT)
    }
}
