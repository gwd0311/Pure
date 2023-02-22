//
//  DetailView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/31.
//

import SwiftUI
import Kingfisher

struct DetailView: View {
    
    
    @ObservedObject var viewModel: DetailViewModel

    @State private var showDialog = false
    @State private var showSendMessageView = false
    @State private var showConversationView = false
    @State private var showReportView = false
    @State private var showBlackView = false
    
    var body: some View {
        let user = viewModel.user
        if let isChatting = viewModel.isChatting {
            VStack {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading) {

                        makeImageSection(user: user)
                        makeUpperSection(user: user)
                        makeLowerSection(user: user)
                        
                        Spacer()
                    }
                    .confirmationDialog("Select", isPresented: $showDialog, actions: {
                        Button {
                            // 차단하기 기능 구현
                            showBlackView.toggle()
                        } label: {
                            Text("차단하기")
                        }
                        Button {
                            // 신고하기 기능 구현
                            showReportView.toggle()
                        } label: {
                            Text("신고하기")
                        }
                    })
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {

                            } label: {
                                Image("more")
                            }
                        }
                    }
                    .navigationTitle(user.nickname)
                    .navigationBarTitleDisplayMode(.inline)
                }
                makeBottomSection(user: user, isChatting: isChatting)
                makeNavLinks(user: user)
                    .hidden()
            }
            .overlay(
                self.showReportView ? ReportView(user: user, showReportView: $showReportView) : nil
            )
            .overlay(
                self.showBlackView ? BlackView(uid: user.id ?? "", showBlackView: $showBlackView) : nil
            )
            .padding(.bottom, 20)
            .edgesIgnoringSafeArea(.bottom)
            .customNavBarItems(trailing: moreButton)
            .customNavigationTitle(user.nickname)
        } else {
            LoadingView()
                .task {
                    await self.viewModel.fetchChattingInfo()
                }
        }
    }
    
    // MARK: - NavLinks
    @ViewBuilder private func makeNavLinks(user: User) -> some View {
        VStack(spacing: 0) {
            CustomNavigationLink(destination: {
                SendMessageView(viewModel: SendMessageViewModel(user: user), onDimiss: {
                    Task {
                        await viewModel.fetchChattingInfo()
                    }
                })
            }, isActive: $showSendMessageView) {
                Text("")
                    .hidden()
            }
            CustomNavigationLink(destination: {
                if let chat = viewModel.chat {
                    ConversationView(chat: chat)
                } else {
                    Text("오류가 발생했습니다.")
                }
            }, isActive: $showConversationView) {
                Text("")
                    .hidden()
            }
        }
        .frame(height: 1)
    }
    
    // MARK: - 프로필 이미지
    @ViewBuilder private func makeImageSection(user: User) -> some View {
        Group {
            if !user.profileImageUrl.isEmpty {
                Color.clear
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        KFImage(URL(string: user.profileImageUrl))
                            .resizable()
                            .frame(maxWidth: .infinity)
                            .scaledToFill()
                    )
                    .frame(maxWidth: .infinity)
                    .clipShape(Rectangle())
                    .contentShape(Rectangle())
            } else if user.gender == .man {
                Image("man")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            } else {
                Image("woman")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - 프로필 닉네임, 성별 등 상세정보
    @ViewBuilder private func makeUpperSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(user.nickname)
                    .font(.system(size: 22, weight: .bold))
                    .padding(.bottom, 10)
                Spacer()
                if user.timestamp.dateValue().isNew() {
                    Image("new")
                    .padding(.bottom)
                }
            }
            HStack(spacing: 4) {
                Text(user.gender == .man ? "남자" : "여자")
                    .foregroundColor(user.gender == .man ? ColorManager.blue : ColorManager.pink)
                    .font(.system(size: 14))
                Group {
                    Text("·")
                    Text("\(user.age)살")
                    Text("·")
                    Text(user.region.title)
                }
                .foregroundColor(ColorManager.black400)
                .font(.system(size: 14))
                Spacer()
            }
            .padding(.bottom, 20)
            Divider()
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 20)
    }
    
    // MARK: - 내 소개 정보
    @ViewBuilder private func makeLowerSection(user: User) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("내 소개")
                .font(.system(size: 16, weight: .bold))
                .padding(.bottom, 10)
            Text(user.introduction)
                .font(.system(size: 16))
                .foregroundColor(ColorManager.black400)
        }
        .padding(.horizontal, 18)
    }
    
    // MARK: - 하단 좋아요 및 메시지 전송
    @ViewBuilder private func makeBottomSection(user: User, isChatting: Bool) -> some View {
        HStack {
            Button {
                // 좋아요 기능 구현
                viewModel.pressLikeButton()
            } label: {
                VStack(spacing: 0) {
                    Image(viewModel.isHeartPressed ? "heart_fill" : "heart")
                    Text("좋아요")
                        .foregroundColor(ColorManager.redLight)
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 17)
            .disabled(user.id == AuthViewModel.shared.currentUser?.id ? true : false)
            
            if isChatting {
                Button {
                    showConversationView.toggle()
                } label: {
                    Text("대화방으로 이동하기")
                }
                .buttonStyle(MainButtonStyle(color: ColorManager.pinkDark))
            } else {
                Button {
                    showSendMessageView.toggle()
                } label: {
                    Text("메시지 전송")
                }
                .buttonStyle(MainButtonStyle(color: user.id != AuthViewModel.shared.currentUser?.id ? ColorManager.blue : ColorManager.black200))
                .disabled(user.id == AuthViewModel.shared.currentUser?.id ? true : false)
            }
        }
        .padding(.horizontal, 18)
        .padding(.top, 8)
    }
    
    // MARK: - 우측 상단 더보기 버튼
    private var moreButton: some View {
        Button {
            showDialog.toggle()
            self.showBlackView = false
            self.showReportView = false
        } label: {
            Image("more")
        }
    }
    
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(viewModel: DetailViewModel(user: MOCK_USER))
    }
}
