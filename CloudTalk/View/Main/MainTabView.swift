//
//  MainTabView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import SwiftUI

struct MainTabView: View {
    
    @EnvironmentObject var tempViewModel: AuthViewModel
    @State private var selectedIndex = 0
    
    var body: some View {
        NavigationView {
            TabView(selection: $selectedIndex) {
                Button(action: {
                    withAnimation {
                        tempViewModel.signOut()
                    }
                }, label: {
                    Text("로그아웃")
                })
                    .onTapGesture {
                        selectedIndex = 0
                    }
                    .tabItem {
                        Image(systemName: "cloud.fill")
                    }
                    .tag(0)
                
                Text("Main")
                    .onTapGesture {
                        selectedIndex = 1
                    }
                    .tabItem {
                        Image(systemName: "bubble.left.and.bubble.right")
                    }
                    .tag(1)
                
                Text("Chat")
                    .onTapGesture {
                        selectedIndex = 2
                    }
                    .tabItem {
                        Image(systemName: "envelope.fill")
                    }
                    .tag(2)
                
                Text("Settings")
                    .onTapGesture {
                        selectedIndex = 3
                    }
                    .tabItem {
                        Image(systemName: "gearshape.fill")
                    }
                    .tag(3)
            }
            .tint(.cyan)
            .navigationBarItems(leading: Text(tabTitle).font(.cookieRun(.bold, size: 24)))
        }
        .onAppear {
            print(AuthViewModel.shared.currentUser?.id)
        }
    }
    
    var tabTitle: String {
        switch selectedIndex {
        case 0: return "새로운 친구들"
        case 1: return "채널"
        case 2: return "채팅"
        case 3: return "설정"
        default: return ""
        }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
