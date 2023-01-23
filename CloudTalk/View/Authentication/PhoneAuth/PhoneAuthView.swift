//
//  PhoneAuthView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/19.
//

import SwiftUI

struct PhoneAuthView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var showAlert = false
    @State private var showVerificationView = false
    
    var body: some View {
        NavigationView {
            VStack {
                
                titlePart
                
                Image("phoneAuth")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal, 80)
                
                inputPart
                
                NavigationLink(destination: VerificationView(), isActive: $viewModel.showVerificationView) {
                    Text("")
                        .hidden()
                }
                
                authButton
                
                Spacer()
            }
            .alert("알림", isPresented: $showAlert, actions: {
                
            }, message: {
                Text(viewModel.alertMsg)
            })
            .onReceive(viewModel.$showAlert) { showAlert in
                self.showAlert = showAlert
            }
            .onReceive(viewModel.$showVerificationView) { showVerificationView in
                self.showVerificationView = showVerificationView
            }
        }
    }
    
    private var titlePart: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 30)
            HStack {
                Text("휴대폰 인증")
                    .font(.cookieRun(.bold, size: 24))
                    .padding(.leading, 30)
                Spacer()
            }
            Spacer().frame(height: 10)
            Text("구름톡 계정을 생성하기 위해 휴대폰 인증을 진행해주세요!")
                .font(.cookieRun(.regular, size: 14))
                .foregroundColor(Color(.systemGray))
                .padding(.leading, 30)
        }
    }
    
    private var inputPart: some View {
        HStack(spacing: 20) {
            Text("🇰🇷 +82")
            TextField("휴대폰 번호 입력 (- 없이)", text: $viewModel.phoneNumber)
                .font(.system(size: 20))
                .keyboardType(.numberPad)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .frame(height: 2)
                        .padding(.top, 10)
                        .offset(y: 10)
                    , alignment: .bottom
                )
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 30)
    }
    
    private var authButton: some View {
        VStack {
            Button {
                viewModel.sendCode()
            } label: {
                Text("인증하기")
                    .font(.cookieRun(.regular))
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(MainButtonStyle(color: .blue))
            .padding(.horizontal, 20)
        }
    }
}

struct PhoneAuthView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneAuthView()
            .environmentObject(AuthViewModel())
    }
}
