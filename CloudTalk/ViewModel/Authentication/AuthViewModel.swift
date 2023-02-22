//
//  AuthViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import Firebase
import FirebaseAuth
import SwiftUI
import CryptoKit
import AuthenticationServices
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

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
    @Published var isLoading = false
    
    static let shared = AuthViewModel()
    
    override init() {
        super.init()
        userSession = Auth.auth().currentUser
        
        fetchUser()
    }
    
    var blackUids: [String] {
        self.currentUser?.blackUids ?? []
    }
    
    func unBlock(uid: String, onUnBlock: @escaping () -> Void) {
        /// firestore의 arrayRemove는 timestamp가 저장될 경우, 같은 문자열이라도 다르게 저장할 수 있다.
        /// 그렇기 때문에 getDocument로 지울 항목을 가져와서 지워야한다.
        
        let ref = COLLECTION_USERS.document(currentUser?.id ?? "")
        
        ref.updateData([
            KEY_BLACK_UIDS: FieldValue.arrayRemove([uid])
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onUnBlock()
            }
        }
    }
    
    func updateCurrentUser(
        image: UIImage?,
        nickname: String,
        gender: Gender,
        age: Int,
        region: Region,
        introduction: String,
        onUpdate: @escaping () -> Void
    ) {
        guard let uid = self.currentUser?.id else { return }
        
        if let image = image {
            if let profileUrl = currentUser?.profileImageUrl {
                if !profileUrl.isEmpty {
                    let ref = Storage.storage().reference(forURL: profileUrl)
                    ref.delete { err in
                        if let err = err {
                            print(err.localizedDescription)
                        }
                    }
                }
            }

            ImageUploader.uploadImage(image: image) { imgUrl in
                let data: [String: Any] = [
                    KEY_PROFILE_IMAGE_URL: imgUrl,
                    KEY_NICKNAME: nickname,
                    KEY_GENDER: gender.rawValue,
                    KEY_AGE: age,
                    KEY_REGION: region.rawValue,
                    KEY_INTRODUCTION: introduction
                ]
                COLLECTION_USERS.document(uid).updateData(data) { err in
                    if let err = err {
                        print(err.localizedDescription)
                        return
                    }
                    onUpdate()
                }
            }
            
        } else {
            let data: [String: Any] = [
                KEY_NICKNAME: nickname,
                KEY_GENDER: gender,
                KEY_AGE: age,
                KEY_REGION: region,
                KEY_INTRODUCTION: introduction
            ]
            COLLECTION_USERS.document(uid).updateData(data) { err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                onUpdate()
            }
        }
    }
    
    private func updateData() {
        
    }
    
    func blackUser(uid: String, completion: @escaping () -> Void) {
        guard let currentUid = currentUser?.id else { return }
        COLLECTION_USERS.document(currentUid).updateData([
            KEY_BLACK_UIDS: FieldValue.arrayUnion([uid])
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            self.fetchUser()
            completion()
        }
    }
    
    func sendCode() {
        
        let number = "+82\(phoneNumber)"
        
        self.isLoading = true
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { code, err in
            self.isLoading = false
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
        self.isLoading = true
        Auth.auth().signIn(with: credential) { result, err in
            self.isLoading = false
            if let err = err {
                print("Error:: \(err)")
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
        self.isLoading = true
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { code, err in
            self.isLoading = false
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
        self.currentUser = nil
        self.alertMsg = ""
        self.showAlert = false
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
