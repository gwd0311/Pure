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
    
    init() {
        UITableView.appearance().showsVerticalScrollIndicator = false
    }
    
    var body: some View {
        
        if isLoading {
            SplashView()
                .onAppear {
                    Task {
                        try? await Task.sleep(nanoseconds: 1_500_000_000)
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
                        .tint(.black)
                    }
                    else {
                        NavigationView {
                            MainTabView()
                        }
                        .tint(.black)
                    }
                } else if viewModel.userSession != nil {
                    RegistrationView()
                } else {
                    LoginView()
                }
            }
            .onAppear {
                print(viewModel.currentUser)
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
