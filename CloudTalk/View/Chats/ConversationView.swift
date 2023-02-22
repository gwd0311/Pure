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
    
    @State private var newMessageID: String? = nil
    
    private let chat: Chat
    
    init(chat: Chat) {
        self.chat = chat
        self.viewModel = ConversationViewModel(chat: chat)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: 0) {
                        makeProfiles()
                            .padding(.top, 16)
                            .padding(.bottom, 18)
                        ChatList(
                            messages: $viewModel.messages,
                            profileImageUrl: viewModel.partnerProfileImageUrl,
                            gender: viewModel.partnerGender
                        )
                        if chat.uids.count == 1 {
                            // TODO: 상대방이 대화를 종료했습니다.
                            Text("상대방이 대화를 종료했습니다.")
                                .font(.system(size: 14, weight: .light))
                                .foregroundColor(ColorManager.red)
                                .padding(.top, 6)
                                .padding(.bottom, 292)
                        }
                        HStack { Spacer() }.id("Scroll")
                    }
                }
                .onChange(of: viewModel.messages) { _ in
                    if let lastMessage = viewModel.messages.last {
                        self.newMessageID = lastMessage.id
                    }
                }
                .onAppear {
                    if let lastMessage = viewModel.messages.last {
                        proxy.scrollTo(lastMessage.id, anchor: .bottom)
                    }
                }
                .onChange(of: newMessageID) { id in
                    if let id = id {
                        proxy.scrollTo(id, anchor: .bottom)
                    }
                }
                if chat.uids.count == 2 {
                    makeMessageInput(proxy: proxy)
                } else {
                    // TODO: 대화방 나가기 버튼
                    makeExitButton()
                }
            }
            .onWillDisappear {
                self.viewModel.read()
            }
            .onAppear {
                self.viewModel.startListen()
            }
            .onDisappear {
                self.viewModel.stopListen()
            }
            .resignKeyboard()
            .onReceive(NotificationCenter.default.publisher(for: UIResponder.keyboardDidShowNotification), perform: { _ in
                withAnimation {
                    proxy.scrollTo("Scroll", anchor: .bottom)
                }
            })
            .customNavigationTitle(viewModel.partnerNickName)
            .customNavBarItems(trailing: trailingItems)
        }
        .confirmationDialog("Select", isPresented: $showDialog) {
            Button("차단하기") {
                
            }
            Button("신고하기") {
                
            }
        }
    }
    
    
    
    // MARK: - 대화방 나가기 버튼
    @ViewBuilder private func makeExitButton() -> some View {
        Button {
            // TODO: 데이터베이스에서 삭제하기
            dismiss()
        } label: {
            Text("대화방 나가기")
        }
        .buttonStyle(MainButtonStyle(color: ColorManager.black250))
        .frame(height: 55)
        .padding(.horizontal, 18)
    }
    
    // MARK: - 하단 채팅 입력창
    @ViewBuilder private func makeMessageInput(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(ColorManager.black50)
                .frame(height: 1)
            HStack(spacing: 0) {
                HStack(spacing: 0) {
                    MultilineTextField("새 메시지 입력", text: $text)
                    Spacer()
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 10)
                
                Button {
                    viewModel.sendMessage(text)
                    self.text = ""
                } label: {
                    VStack(spacing: 0) {
                        if text.isEmpty {
                            Image("sendBtn_off")
                        } else {
                            Image("sendBtn_on")
                        }
                    }
                    .frame(width: 52, height: 52)
                }
                .padding(.trailing, 8)
                .disabled(text.isEmpty)
            }
        }
    }
    
    //MARK: - 상단 프로필 정보
    @ViewBuilder private func makeProfiles() -> some View {
        VStack(spacing: 12) {
            VStack(spacing: 0) {
                ZStack {
                    HStack(spacing: 0) {
                        Spacer()
                        ProfileImageView(profileImageUrl: viewModel.currentProfileImageUrl, gender: viewModel.currentGender, type: .circle)
                    }
                    HStack(spacing: 0) {
                        ProfileImageView(profileImageUrl: viewModel.partnerProfileImageUrl, gender: viewModel.partnerGender, type: .circle)
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
                Text(viewModel.partnerNickName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(ColorManager.blue)
                Text("\(viewModel.partnerAge)세 \(viewModel.partnerGender.title)")
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
