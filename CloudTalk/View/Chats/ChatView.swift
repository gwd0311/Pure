//
//  ChatView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/06.
//

import SwiftUI

struct ChatView: View {
    
    @StateObject var viewModel = ChatViewModel()
    @State private var isEmpty = false
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            ColorManager.backgroundColor.ignoresSafeArea()
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(36, corners: .topLeft)
                .edgesIgnoringSafeArea(.bottom)
                .padding(.top, 5)
            if isEmpty && !isLoading {
                VStack(spacing: 0) {
                    Image("cloud_sad")
                        .padding(.bottom, 18)
                    Text("진행 중인 대화가 없습니다.")
                        .foregroundColor(ColorManager.black500)
                        .font(.system(size: 16, weight: .bold))
                }
            }
            VStack(spacing: 0) {
                Spacer().frame(height: 5)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.chats) { chat in
                                CustomNavigationLink {
                                    // 뷰모델에서 user가져오기
                                    ConversationView(chat: chat)
                                        .id(chat.id)
                                } label: {
                                    ChatCell(chat: chat, onDelete: { chat in
                                        // 뷰모델에서 삭제 구현
                                        viewModel.delete(chat: chat)
                                    })
                                        .id(chat.id)
                                        .task {
                                            if viewModel.chats.count > 8 {
                                                await viewModel.fetchMore(chat: chat)
                                            }
                                        }
                                }
                                .buttonStyle(NoTransparencyButtonStyle())
                            }
                            Spacer().frame(height: 200)
                        }
                    }
                }
                .cornerRadius(36, corners: .topLeft)
            }
        }
        .overlay(
            isLoading ? LoadingView() : nil
        )
        
        .task {
            self.viewModel.startListen()
            isLoading = true
            try? await Task.sleep(nanoseconds: 0_100_000_000)
            self.isEmpty = viewModel.chats.isEmpty
            isLoading = false
        }
        .onDisappear {
            self.viewModel.stopListen()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                titleLabel
            }
        }
    }
    
    private var titleLabel: some View {
        Text("채팅방")
            .foregroundColor(.white)
            .font(.bmjua(.regular, size: 24))
    }
    
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(viewModel: ChatViewModel())
    }
}

struct NoTransparencyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.gray : Color.black)
    }
}
