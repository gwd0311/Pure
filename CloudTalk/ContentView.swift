//
//  ContentView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import SwiftUI

struct ContentView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        Group {
            if viewModel.userSession != nil && viewModel.currentUser != nil {
                MainTabView()
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
