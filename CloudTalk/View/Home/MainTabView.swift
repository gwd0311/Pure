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
                .background(ColorManager.tabBar)
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
                Text("메인")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(tabIndex == .main ? ColorManager.backgroundColor : ColorManager.off)
            }
            .frame(width: UIScreen.main.bounds.width / 5)
        }
    }
    
    private var postButton: some View {
        Button {
            tabIndex = .post
        } label: {
            VStack(spacing: 2) {
                Image(tabIndex == .post ? "bottom2On" : "bottom2Off")
                Text("게시물")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(tabIndex == .post ? ColorManager.backgroundColor : ColorManager.off)
            }
            .frame(width: UIScreen.main.bounds.width / 5)
        }
    }
    
    private var chatButton: some View {
        Button {
            tabIndex = .chat
        } label: {
            VStack(spacing: 2) {
                Image(tabIndex == .chat ? "bottom3On" : "bottom3Off")
                Text("채팅")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(tabIndex == .chat ? ColorManager.backgroundColor : ColorManager.off)
            }
            .frame(width: UIScreen.main.bounds.width / 5)
        }
    }
    
    private var likeButton: some View {
        Button {
            tabIndex = .like
        } label: {
            VStack(spacing: 2) {
                Image(tabIndex == .like ? "bottom4On" : "bottom4Off")
                Text("좋아요")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(tabIndex == .like ? ColorManager.backgroundColor : ColorManager.off)
            }
            .frame(width: UIScreen.main.bounds.width / 5)
        }
    }
    
    private var settingsButton: some View {
        Button {
            tabIndex = .settings
        } label: {
            VStack(spacing: 2) {
                Image(tabIndex == .settings ? "bottom5On" : "bottom5Off")
                Text("설정")
                    .font(.system(size: 12, weight: .black))
                    .foregroundColor(tabIndex == .settings ? ColorManager.backgroundColor : ColorManager.off)
            }
            .frame(width: UIScreen.main.bounds.width / 5)
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        
        let model = AuthViewModel()
        
        MainTabView()
            .environmentObject(model)
    }
}

enum TabIndex {
    case main, post, chat, like, settings
}
