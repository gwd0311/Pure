//
//  VerificationView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/19.
//

import SwiftUI

struct VerificationView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    
    @State private var showAlert = false
    
    var body: some View {
        VStack {
            titlePart
            
            inputPart
            
            verifyButton
            
            Spacer()
        }
        .alert("알림", isPresented: $showAlert, actions: {
            
        }, message: {
            Text(viewModel.alertMsg)
        })
        .onReceive(viewModel.$showAlert) { showAlert in
            self.showAlert = showAlert
        }
    }
    
    private var titlePart: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 30)
            HStack {
                Text("인증번호 입력")
                    .font(.cookieRun(.bold, size: 24))
                    .padding(.leading, 30)
                Spacer()
            }
            Spacer().frame(height: 10)
            Text("휴대폰 번호로 발송된 인증번호를 3분 내에 입력해주세요!")
                .font(.cookieRun(.regular, size: 14))
                .foregroundColor(Color(.systemGray))
                .padding(.leading, 30)
                .padding(.bottom, 50)
        }
    }
    
    private var inputPart: some View {
        VStack {
            TextField("인증번호 입력", text: $viewModel.verificationCode)
                .font(.system(size: 20))
                .keyboardType(.numberPad)
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .frame(height: 2)
                        .padding(.top, 10)
                        .offset(y: 10)
                    , alignment: .bottom
                )
                .padding(.bottom, 10)
            HStack {
                Spacer()
                Button {
                    viewModel.requestCode()
                } label: {
                    Text("인증번호 재전송")
                        .font(.cookieRun(.regular))
                }
            }
            .padding(.trailing, 10)
            .padding(.bottom, 50)
        }
        .padding(.horizontal, 20)
    }
    
    private var verifyButton: some View {
        VStack {
            Button {
                viewModel.verifyCode()
            } label: {
                Text("인증번호 확인")
                    .font(.cookieRun(.regular))
            }
            .frame(maxWidth: .infinity)
            .buttonStyle(MainButtonStyle(color: .blue))
            .padding(.horizontal, 20)
        }
    }
}

struct VerificationView_Previews: PreviewProvider {
    static var previews: some View {
        VerificationView()
    }
}
