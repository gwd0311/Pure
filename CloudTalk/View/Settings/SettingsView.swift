//
//  SettingsView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/27.
//

import SwiftUI
import Firebase

struct SettingsView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        VStack {
            Button {
                viewModel.signOut()
            } label: {
                Text("로그아웃")
            }
            Spacer()
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
