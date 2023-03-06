//
//  ContentView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isLoading = true
    @ObservedObject var networkManager = NetworkManager()
    @State private var showNetworkAlert = false
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    var body: some View {
        
        ZStack {
            if isLoading {
                SplashView()
                    .onAppear {
                        Task {
                            try? await Task.sleep(nanoseconds: 2_000_000_000)
                            withAnimation {
                                isLoading = false
                            }
                        }
                    }
            } else {
                Group {
                    if viewModel.userSession != nil && viewModel.currentUser != nil {
                        if #available(iOS 16.0, *) {
                            NavigationStack {
                                MainTabView()
                            }
                            .navigationViewStyle(StackNavigationViewStyle())
                            .tint(.black)
                        }
                        else {
                            NavigationView {
                                MainTabView()
                            }
                            .navigationViewStyle(StackNavigationViewStyle())
                            .tint(.black)
                        }
                    } else if viewModel.userSession != nil {
                        RegistrationView()
                    } else {
                        LoginView()
                    }
                }
                .onAppear {
                    networkManager.startMonitoring()
                    if networkManager.isConnected {
                        print("잘 연결되었습니다.")
                    } else {
                        self.showNetworkAlert.toggle()
                    }
                }
            }
            Text("")
                .alert(isPresented: $showNetworkAlert) {
                    Alert(title: Text("알림"), message: Text("네트워크 연결이 불안정합니다\n네트워크 연결 확인 후 다시이용해주세요"), dismissButton: .default(Text("확인"), action: {
                        viewModel.systemOff()
                    }))
                }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
