//
//  LoginView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import SwiftUI
import AuthenticationServices
import SDWebImageSwiftUI

struct LoginView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showPhoneRegisterView = false
    @State private var imageData: Data? = nil
    @State private var showGif = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(colors: [ColorManager.skyBlueDark, ColorManager.purpleDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                CustomNavigationLink(
                    destination: { PhoneAuthView() },
                    isActive: $showPhoneRegisterView,
                    label: {
                        Text("").hidden()
                    }
                )
                
                VStack(spacing: 10) {
                    
                    if showGif {
                        AnimatedImage(name: "cloudMain.gif")
                            .resizable()
                            .frame(width: 280, height: 280)
                    } else {
                        ProgressView()
                            .frame(width: 280, height: 280)
                    }
                    
                    Image("cloudtalk")
                        .padding(.bottom, 20)
                    
                    VStack {
                        Text("가까운 동네친구 찾기")
                            .font(.system(size: 26, weight: .black))
                            .padding(.top, 44)
                            .padding(.bottom, 14)
                        Text("구름톡에서 연령, 성별, 지역별로 자유롭게\n마음이 맞는 친구들을 찾아보세요!")
                            .font(.system(size: 15, weight: .light))
                            .foregroundColor(ColorManager.black400)
                            .multilineTextAlignment(.center)
                        Spacer()
                        appleLoginButton
                            .padding(.bottom, 6)
                        phoneLoginButton
                    }
                    .frame(maxWidth: .infinity)
                    .background(.white)
                    .cornerRadius(30, corners: [.topLeft, .topRight])
                    .ignoresSafeArea()
                }
            }
            .onAppear {
                self.showGif = true
            }
            .onDisappear {
                self.showGif = false
            }
        }
    }
    
    private var phoneLoginButton: some View {
        Button {
            // 휴대폰 인증화면으로 가기
            withAnimation {
                showPhoneRegisterView.toggle()
            }
        } label: {
            HStack {
                Image("phone")
                Text("휴대폰 번호로 시작하기")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(ColorManager.black600)
            }
            .frame(height: 58)
            .frame(maxWidth: .infinity)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(lineWidth: 2)
                    .foregroundColor(ColorManager.black150)
            )
            .padding(.horizontal, 30)
            .padding(.bottom, 130)
        }
    }
    
    private var appleLoginButton: some View {
        SignInWithAppleButton(.signIn) { request in
            // 애플로그인에 파라미터를 요청하기
            viewModel.nonce = viewModel.randomNonceString()
            request.requestedScopes = [.email, .fullName]
            request.nonce = viewModel.sha256(viewModel.nonce)
        } onCompletion: { result in
            // 성공 or 실패 결과 받기
            switch result {
            case .success(let user):
                print("success")
                // Firebase에 로그인하기
                guard let credential = user.credential as? ASAuthorizationAppleIDCredential else {
                    print("error with firebase")
                    return
                }
                viewModel.authenticate(credential: credential)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
        .signInWithAppleButtonStyle(.black)
        .frame(height: 58)
        .cornerRadius(16)
        .padding(.horizontal, 30)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
