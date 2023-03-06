//
//  MainTabView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var tabIndex: TabIndex = .main
    @State private var showBanAlert = false
    @State private var isNewChat = false
    @State private var showNetworkAlert = false
    
    private let deviceWidth = UIScreen.main.bounds.size.width - 32
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Color.white.edgesIgnoringSafeArea(.all)
            selectedView
            Group {
                VStack {
                    Spacer()
                    Rectangle()
                        .foregroundColor(.red)
                        .frame(height: 58)
                        .shadow(color: ColorManager.shadow.opacity(0.08), radius: 4, x: 0, y: 1)
                }
                .padding(.bottom, 20)
                VStack(spacing: 0) {
                    if tabIndex == .main || tabIndex == .post {
                        AdaptiveBanner()
                            .frame(height: 58)
                    }
                    Rectangle()
                        .foregroundColor(ColorManager.black30)
                        .frame(height: 1)
                    HStack(spacing: 0) {
                        mainButton
                        postButton
                        chatButton
                        likeButton
                        settingsButton
                    }
                    .frame(height: 58)
                    .frame(maxWidth: .infinity)
                    .padding(.bottom, 20)
                    .padding(.horizontal, 16)
                    .background(ColorManager.tabBar)
                    Text("")
                        .alert(isPresented: $showBanAlert, content: {
                            Alert(title: Text("알림"), message: Text("서비스 이용 중 정책을 위반한 사례가 발견되어 영구정지되었습니다.\n문의사항이 있으실 경우 gwd0311@naver.com으로 문의바랍니다."), dismissButton: .default(Text("확인"), action: {
                                viewModel.systemOff()
                            }))
                        })
                }
            }
        }
        .onAppear {
            viewModel.fetchUser()
            viewModel.checkBanList { isBan in
                if isBan {
                    self.showBanAlert.toggle()
                }
            }
            viewModel.checkNewChat { isNew in
                self.isNewChat = isNew
            }
        }
        .edgesIgnoringSafeArea(.bottom)
    }
    
    private var selectedView: some View {
        VStack {
            switch tabIndex {
            case .main:
                MainView()
            case .post:
                PostView()
            case .chat:
                ChatView(viewModel: ChatViewModel())
            case .like:
                LikeView()
            case .settings:
                SettingsView()
            }
        }
    }
    
    private var mainButton: some View {
        Button {
            tabIndex = .main
        } label: {
            VStack(spacing: 2) {
                Image(tabIndex == .main ? "bottom1On" : "bottom1Off")
                    .resizable()
                    .frame(width: 28, height: 28)
                Text("메인")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(tabIndex == .main ? ColorManager.backgroundColor : ColorManager.off)
            }
            .frame(width: deviceWidth / 5)
        }
    }
    
    private var postButton: some View {
        Button {
            tabIndex = .post
        } label: {
            VStack(spacing: 2) {
                Image(tabIndex == .post ? "bottom2On" : "bottom2Off")
                    .resizable()
                    .frame(width: 28, height: 28)
                Text("게시물")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(tabIndex == .post ? ColorManager.backgroundColor : ColorManager.off)
            }
            .frame(width: deviceWidth / 5)
        }
    }
    
    private var chatButton: some View {
        Button {
            tabIndex = .chat
        } label: {
            VStack(spacing: 2) {
                Image(tabIndex == .chat ? "bottom3On" : "bottom3Off")
                    .resizable()
                    .frame(width: 28, height: 28)
                    .overlay(
                        self.isNewChat ? Circle()
                            .frame(width: 10, height: 10)
                            .foregroundColor(ColorManager.red)
                            .padding(.leading, 4) : nil
                        , alignment: .topTrailing
                    )
                Text("채팅")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(tabIndex == .chat ? ColorManager.backgroundColor : ColorManager.off)
            }
            .frame(width: deviceWidth / 5)
        }
    }
    
    private var likeButton: some View {
        Button {
            tabIndex = .like
        } label: {
            VStack(spacing: 2) {
                Image(tabIndex == .like ? "bottom4On" : "bottom4Off")
                    .resizable()
                    .frame(width: 28, height: 28)
                Text("좋아요")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(tabIndex == .like ? ColorManager.backgroundColor : ColorManager.off)
            }
            .frame(width: deviceWidth / 5)
        }
    }
    
    private var settingsButton: some View {
        Button {
            tabIndex = .settings
        } label: {
            VStack(spacing: 2) {
                Image(tabIndex == .settings ? "bottom5On" : "bottom5Off")
                    .resizable()
                    .frame(width: 28, height: 28)
                Text("설정")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(tabIndex == .settings ? ColorManager.backgroundColor : ColorManager.off)
            }
            .frame(width: deviceWidth / 5)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        
        let model = AuthViewModel()
        
        MainTabView()
            .environmentObject(model)
            .environmentObject(model.interstitialAd)
    }
}

enum TabIndex {
    case main, post, chat, like, settings
}
