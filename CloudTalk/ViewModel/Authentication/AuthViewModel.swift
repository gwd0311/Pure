//
//  AuthViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import Firebase
import FirebaseAuth
import FirebaseFirestore
import SwiftUI
import CryptoKit
import AuthenticationServices

@MainActor
class AuthViewModel: NSObject, ObservableObject {
    
    @Published var nonce = ""
    @Published var phoneNumber: String = ""
    @Published var verificationCode: String = ""
    @Published var userSession: Firebase.User?
    @Published var currentUser: User?
    @Published var verificationId: String = ""
    @Published var showVerificationView = false
    
    @Published var alertMsg = ""
    @Published var showAlert = false
    
    static let shared = AuthViewModel()
    
    override init() {
        super.init()
        userSession = Auth.auth().currentUser
        
        fetchUser()
    }
    
    func sendCode() {
        
        let number = "+82\(phoneNumber)"
        
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { code, err in
            
            if err != nil {
                self.alertMsg = "인증이 잘못되었습니다."
                withAnimation {
                    self.showAlert.toggle()
                }
                return
            }
            
            self.verificationId = code ?? ""
            self.showVerificationView.toggle()
        }
    }
    
    func verifyCode() {
        
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationId, verificationCode: verificationCode)
        
        Auth.auth().signIn(with: credential) { result, err in
            if let _ = err {
                self.alertMsg = "인증번호 검증이 잘못되었습니다."
                withAnimation {
                    self.showAlert.toggle()
                }
                return
            }
            
            withAnimation {
                self.userSession = result?.user
                self.fetchUser()
            }
        }
        
    }
    
    func requestCode() {
        
        let number = "+82\(phoneNumber)"
        
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { code, err in
            
            if err != nil {
                self.alertMsg = "인증번호 재전송 중 오류가 발생하였습니다."
                withAnimation {
                    self.showAlert.toggle()
                }
                return
            }
            
            self.verificationId = code ?? ""
            
            withAnimation {
                self.alertMsg = "인증번호가 발송되었습니다."
                self.showAlert.toggle()
            }
        }
        
    }
    
    func signOut() {
        self.userSession = nil
        try? Auth.auth().signOut()
    }
    
    func fetchUser() {
        guard let uid = userSession?.uid else { return }
        
        COLLECTION_USERS.document(uid).getDocument { snapshot, _ in
            guard let user = try? snapshot?.data(as: User.self) else { return }
            self.currentUser = user
        }
    }
    
    // MARK: - 애플 로그인
    func authenticate(credential: ASAuthorizationAppleIDCredential) {
        // 토큰 얻어오기
        guard let token = credential.identityToken else {
            print("error with firebase")
            return
        }
        
        // 토큰 문자열로 바꾸기
        guard let tokenString = String(data: token, encoding: .utf8) else {
            print("error with Token")
            return
        }
        
        let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
        
        Auth.auth().signIn(with: firebaseCredential) { result, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            // User Successfully Logged Into Firebase
            print("Logged In Success")
            
            // 유저를 홈페이지로 넘기기
            withAnimation {
                self.userSession = result?.user
                self.fetchUser()
            }
        }
    }
    
}

enum ProfileInfo {
    case nickname, gender, age, region, introduction
}

// MARK: - 애플 로그인 도와주는 함수들
extension AuthViewModel {
    
    func sha256(_ input: String) -> String {
      let inputData = Data(input.utf8)
      let hashedData = SHA256.hash(data: inputData)
      let hashString = hashedData.compactMap {
        String(format: "%02x", $0)
      }.joined()

      return hashString
    }

    func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
}
