//
//  DetailView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/31.
//

import SwiftUI
import Kingfisher

struct DetailView: View {
    
    let user: AppUser
    let ableToNavigate: Bool
    @ObservedObject var viewModel: DetailViewModel
    
    init(user: AppUser, ableToNavigate: Bool = true) {
        self.user = user
        self.ableToNavigate = ableToNavigate
        self.viewModel = DetailViewModel(user: user)
    }
    
    @State private var showDialog = false
    @State private var showSendMessageView = false
    @State private var showConversationView = false
    @State private var showReportView = false
    @State private var showBlackView = false
    
    var body: some View {
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
                    if AuthViewModel.shared.isManager {
                        Button(role: .destructive) {
                            // TODO: 영구정지 기능 구현
                            viewModel.ban()
                        } label: {
                            Text("영구정지")
                        }
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
            if ableToNavigate {
                makeBottomSection(user: user, isChatting: viewModel.isChatting)
            }
            makeNavLinks(user: user)
                .hidden()
        }
        .onAppear {
            viewModel.fetchHeartPressedInfo()
            Task {
                await viewModel.fetchChattingInfo()
                await viewModel.fetchMessagesCount()
            }
        }
        .overlay(
            self.showReportView ? ReportView(uid: user.id ?? "", showReportView: $showReportView) : nil
        )
        .overlay(
            self.showBlackView ? BlackView(uid: user.id ?? "", showBlackView: $showBlackView) : nil
        )
        .padding(.bottom, 20)
        .edgesIgnoringSafeArea(.bottom)
        .customNavBarItems(trailing: moreButton)
        .customNavigationTitle(user.nickname)
    }
    
    // MARK: - NavLinks
    @ViewBuilder private func makeNavLinks(user: AppUser) -> some View {
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
    @ViewBuilder private func makeImageSection(user: AppUser) -> some View {
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
    @ViewBuilder private func makeUpperSection(user: AppUser) -> some View {
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
            PersonalInfoView(
                gender: user.gender,
                age: user.age,
                region: user.region,
                fontSize: 14
            )
            .padding(.bottom, 20)
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text("직업")
                    Spacer()
                    Text("\(user.job.title) / \(user.company)")
                        .font(.system(size: 18, weight: .black))
                        .foregroundColor(ColorManager.blue)
                        .blur(radius: viewModel.blurRadius)
                }
                .padding(.horizontal, 18)
                .padding(.vertical, 14)
            }
            .background(ColorManager.black50)
            .cornerRadius(18)
            .padding(.bottom, 20)
            Divider()
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 20)
    }
    
    // MARK: - 내 소개 정보
    @ViewBuilder private func makeLowerSection(user: AppUser) -> some View {
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
    @ViewBuilder private func makeBottomSection(user: AppUser, isChatting: Bool?) -> some View {
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
            if let isChatting = isChatting {
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
            } else {
                Button {
                    
                } label: {
                    Text("데이터 불러오는 중..")
                }
                .buttonStyle(MainButtonStyle(color: ColorManager.black200))
                .disabled(false)
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

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView(uid: MOCK_USER)
//    }
//}
