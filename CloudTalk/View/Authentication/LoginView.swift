//
//  LoginView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import SwiftUI
import AuthenticationServices

struct LoginView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showPhoneRegisterView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Image("bg")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width)
                    .overlay(Color.black.opacity(0.35))
                    .ignoresSafeArea()
                
                VStack(spacing: 25) {
                    Text("CloudTalk")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 20) {
                        Text("가까운\n동네친구 찾기")
                            .font(.system(size: 45))
                            .fontWeight(.heavy)
                            .foregroundColor(.white)
                        Text("구름톡에서 연령, 성별, 지역별로 자유롭게 마음이 맞는 친구들을 찾아보세요!")
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 30)
                    
                    Spacer()
                    
                    phoneLoginButton
                    
                    appleLoginButton
                }
            }
            .fullScreenCover(isPresented: $showPhoneRegisterView) {
                PhoneAuthView()
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
            Text("📞  휴대폰 번호로 시작하기")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.black)
                .frame(height: 55)
                .frame(maxWidth: .infinity)
                .background(ColorManager.phoneLoginColor)
                .clipShape(Capsule())
                .padding(.horizontal, 40)
        }
    }
    
    private var appleLoginButton: some View {
        SignInWithAppleButton { request in
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
        .signInWithAppleButtonStyle(.white)
        .frame(height: 55)
        .clipShape(Capsule())
        .padding(.horizontal, 40)
        .padding(.bottom, 70)
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
