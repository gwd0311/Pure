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
    @State private var isLoading = false
    @State private var phoneNumber = ""
    @State private var verificationCode = ""
    @State private var phoneNumberValidationMessage = ""
    @State private var isPhoneNumberAuthComplete = false
    @State private var alertMessage = ""
    @State private var timeRemaining = 180
    @State private var timer: Timer?
    
    var isPhoneNumberCorrect: Bool {
        let pattern = #"^[0-9]{10,11}$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        if regex?.firstMatch(in: phoneNumber, range: NSRange(location: 0, length: phoneNumber.count)) != nil {
            return true
        } else {
            return false
        }
    }
    
    var isVerificationCodeCorrect: Bool {
        let pattern = #"^[0-9]{6,6}$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        if regex?.firstMatch(in: verificationCode, range: NSRange(location: 0, length: verificationCode.count)) != nil {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                
                titleSection
                
                phoneNumberAuthSection
                    .padding(.bottom, 20)
                
                if isPhoneNumberAuthComplete {
                    makeCodeAuthSection()
                }
                
                Spacer()
                authButton
            }
            .onDisappear {
                timer?.invalidate()
                timer = nil
            }
            .alert(isPresented: $showAlert, content: {
                Alert(title: Text("알림"), message: Text(alertMessage), dismissButton: .default(Text("확인"), action: {
                    self.showAlert.toggle()
                }))
            })
            .padding(.horizontal, 20)
        }
        .overlay(isLoading ? LoadingView() : nil)
    }
    
    func startTimer() {
        // 이미 실행 중인 타이머가 있다면, 무효화 (중복 실행 방지)
        timer?.invalidate()
        
        // 1초마다 실행되는 타이머 생성
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 { // 남은 시간이 0보다 크면
                timeRemaining -= 1 // 시간을 1초 줄임
            } else { // 시간이 0이 되었으면
                // 여기서는 인증 코드를 다시 전송하거나, 타이머 종료 등의 처리를 할 수 있음
                timer?.invalidate() // 타이머 무효화
            }
        }
    }
    
    // MARK: - 제목, 부제목
    private var titleSection: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 10)
            HStack {
                Text("회원님의 휴대폰번호를\n입력해주세요")
                    .font(.system(size: 24, weight: .black))
                    .lineSpacing(6)
                Spacer()
            }
            Spacer().frame(height: 4)
            Text("인증을 위한 휴대폰 번호를 입력하세요")
                .font(.system(size: 14, weight: .light))
                .foregroundColor(ColorManager.black300)
        }
        .padding(.bottom, 24)
    }
    
    // MARK: - 휴대폰 번호 인증
    private var phoneNumberAuthSection: some View {
        VStack {
            HStack {
                Text("휴대폰 번호")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(ColorManager.black300)
                Spacer()
            }
            HStack(spacing: 20) {
                TextField("휴대폰 번호 입력", text: $phoneNumber)
                    .font(.system(size: 20))
                    .keyboardType(.numberPad)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .frame(height: 2)
                            .offset(y: 10)
                        , alignment: .bottom
                    )
            }
            .padding(.bottom, 12)
            if !isPhoneNumberCorrect && !phoneNumber.isEmpty {
                HStack {
                    Text("휴대폰번호 형식이 올바르지 않습니다.")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(ColorManager.red)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - 인증번호
    @ViewBuilder private func makeCodeAuthSection() -> some View {
        VStack {
            HStack(spacing: 0) {
                Text("인증 번호 입력")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(ColorManager.black300)
                    .padding(.trailing, 6)
                Text("\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                    .foregroundColor(ColorManager.blue)
                    .font(.system(size: 15, weight: .semibold))
                Spacer()
            }
            HStack(spacing: 20) {
                TextField("인증 번호 입력", text: $verificationCode)
                    .introspectTextField(customize: { textField in
                        textField.becomeFirstResponder()
                    })
                    .font(.system(size: 20))
                    .keyboardType(.numberPad)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .frame(height: 2)
                            .offset(y: 10)
                        , alignment: .bottom
                    )
                    .overlay(
                        Button(action: {
                            isLoading = true
                            viewModel.requestCode(phoneNumber: phoneNumber) { isSuccess in
                                isLoading = false
                                if isSuccess {
                                    self.verificationCode = ""
                                    self.timeRemaining = 180
                                } else {
                                    self.alertMessage = "인증번호 재전송에 실패하였습니다.\n네트워크 상태를 확인해주세요"
                                    self.showAlert.toggle()
                                }
                            }
                        }, label: {
                            Text("재전송")
                                .font(.system(size: 18, weight: .semibold))
                                .foregroundColor(ColorManager.blue)
                        })
                        , alignment: .trailing
                    )
            }
            .padding(.bottom, 12)
            if !isVerificationCodeCorrect && !verificationCode.isEmpty {
                HStack {
                    Text("인증번호 형식이 올바르지 않습니다.")
                        .font(.system(size: 14, weight: .light))
                        .foregroundColor(ColorManager.red)
                    Spacer()
                }
            }
        }
    }
    
    // MARK: - 인증 버튼
    private var authButton: some View {
        VStack{
            if !isPhoneNumberAuthComplete {
                VStack {
                    Button {
                        self.isLoading = true
                        viewModel.sendCode(phoneNumber: self.phoneNumber) { isSuccess in
                            self.isLoading = false
                            if isSuccess {
                                self.isPhoneNumberAuthComplete = true
                                self.startTimer()
                            } else {
                                // TODO: 실패 Alert 띄우기
                                self.alertMessage = "휴대폰 번호 인증에 실패하였습니다."
                                self.showAlert.toggle()
                                print("인증실패")
                            }
                        }
                    } label: {
                        Text("인증 번호 전송")
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(MainButtonStyle(color: isPhoneNumberCorrect ? ColorManager.blue : ColorManager.black150))
                    .frame(height: 55)
                    .disabled(!isPhoneNumberCorrect)
                }
                .padding(.bottom, 10)
            } else {
                VStack {
                    Button {
                        isLoading = true
                        viewModel.verifyCode(verificationCode: verificationCode) { isSuccess in
                            isLoading = false
                            if isSuccess {
                                // TODO: 메인화면으로 이동
                                
                            } else {
                                self.alertMessage = "인증번호 검증에 실패하였습니다\n네트워크 상태를 확인하고 다시 시도해주세요"
                                self.showAlert.toggle()
                            }
                        }
                    } label: {
                        Text("인증 완료")
                    }
                    .frame(maxWidth: .infinity)
                    .buttonStyle(MainButtonStyle(color: isVerificationCodeCorrect ? ColorManager.blue : ColorManager.black150))
                    .frame(height: 55)
                    .disabled(!isVerificationCodeCorrect)
                }
                .padding(.bottom, 10)
            }
        }
    }
}

struct PhoneAuthView_Previews: PreviewProvider {
    static var previews: some View {
        PhoneAuthView()
            .environmentObject(AuthViewModel())
    }
}
