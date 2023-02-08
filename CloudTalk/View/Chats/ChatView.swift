//
//  ChatView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/06.
//

import SwiftUI

struct ChatView: View {
    
    @ObservedObject var viewModel = ChatViewModel()
    
    var body: some View {
        ZStack {
            ColorManager.backgroundColor.ignoresSafeArea()
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(36, corners: .topLeft)
                .edgesIgnoringSafeArea(.bottom)
                .padding(.top, 5)
            if viewModel.chats.isEmpty && !viewModel.isLoading{
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
                                    ConversationView(chat: chat)
                                } label: {
                                    ChatCell(chat: chat)
                                        .id(chat.id)
                                        .task {
                                            if viewModel.chats.count > 8 {
                                                await viewModel.fetchMore(chat: chat)
                                            }
                                        }
                                }
                            }
                        }
                    }
                }
                .refreshable {
                    viewModel.fetchChats()
                }
                .cornerRadius(36, corners: .topLeft)
            }
        }
        .overlay(
            viewModel.isLoading ? LoadingView() : nil
        )
        .onAppear {
            print(viewModel.chats)
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
            .font(.gmarketSans(.bold, size: 24))
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView(viewModel: ChatViewModel())
    }
}
