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
    @Published var userSession: Firebase.User?
    @Published var currentUser: User?
    @Published var verificationId: String = ""
    
    @Published var isPushOn = true
    @Published var isPointAlertComplete = false
    
    var interstitialAd = InterstitialAd()
    
    static let shared = AuthViewModel()
    
    override init() {
        super.init()
        userSession = Auth.auth().currentUser
        
        fetchUser()
    }
    
    // MARK: - 포인트 수령여부
    var isPointReceivedToday: Bool {
        let calendar = Calendar.current
        if let lastPointDate = currentUser?.lastPointDate.dateValue() {
            if calendar.isDateInToday(lastPointDate) {
                return true
            } else {
                return false
            }
        } else {
            return false
        }        
    }
    
    // MARK: - 운영자 여부
    var isManager: Bool {
        if let uid = self.currentUser?.id {
            return uid == M_KEY
        } else {
            return false
        }
    }
    
    // MARK: - 차단 목록
    var blackUids: [String] {
        self.currentUser?.blackUids ?? []
    }
    
    // MARK: - 차단 해제
    func unBlock(uid: String, onUnBlock: @escaping () -> Void) {
        
        let ref = COLLECTION_USERS.document(currentUser?.id ?? "")
        
        ref.updateData([
            KEY_BLACK_UIDS: FieldValue.arrayRemove([uid])
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            self.fetchUser()
            onUnBlock()
        }
    }
    
    // MARK: - 채팅방 프로필정보 업데이트
    /// 채팅방의 경우 addsnapshotListner로 인해 실시간 업데이트를 해줘야해서..
    /// 비동기로 데이터를 가져올 경우 깜빡거리는 현상 등 UX가 불안정해져서 미리 넣어주었다.
    private func updateChatRoomProfile(uid: String, profileImageUrl: String? = nil, nickname: String) {
        COLLECTION_CHATS.whereField(KEY_UIDS, arrayContains: uid).getDocuments { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            snapshot?.documents.forEach({ snapshot in
                
                guard let chat = try? snapshot.data(as: Chat.self) else { return }
                
                if let profileImageUrl = profileImageUrl {
                    var profileImages = chat.userProfileImages
                    var nicknames = chat.userNickNames
                    profileImages[uid] = profileImageUrl
                    nicknames[uid] = nickname
                    
                    snapshot.reference.updateData([
                        KEY_USER_PROFILE_IMAGES: profileImages,
                        KEY_USER_NICKNAMES: nicknames
                    ])
                } else {
                    var nicknames = chat.userNickNames
                    nicknames[uid] = nickname
                    
                    snapshot.reference.updateData([
                        KEY_USER_NICKNAMES: nicknames
                    ])
                }
                
            })
        }
    }
    
    // MARK: - 새로온 채팅 있는지 체크
    func checkNewChat(completionHandler: @escaping (_ isNew: Bool) -> Void) {
        
        guard let uid = currentUser?.id else { return }
        
        COLLECTION_CHATS
            .whereField(KEY_UIDS, arrayContains: uid)
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 1)
            .getDocuments { snapshot, err in
                if let err = err {
                    print(err.localizedDescription)
                    completionHandler(false)
                    return
                }
                
                guard let newChat = try? snapshot?.documents.first?.data(as: Chat.self) else {
                    completionHandler(false)
                    return
                }
                
                guard let partnerUid = newChat.uids.filter({ $0 != uid }).first else { return }
                
                if newChat.unReadMessageCount[partnerUid] == 0 {
                    completionHandler(false)
                } else {
                    completionHandler(true)
                }
            }
    }
    
    // MARK: - 영구정지 목록 체크
    func checkBanList(completionHandler: @escaping (_ isBan: Bool) -> Void) {
        COLLECTION_BANUSERS.document(currentUser?.id ?? "").getDocument { snapshot , err in
            if let err = err {
                print(err.localizedDescription)
                completionHandler(false)
                return
            }
            
            guard (try? snapshot?.data(as: BannedUser.self)) != nil else {
                completionHandler(false)
                return
            }
            
            completionHandler(true)
        }
    }
    
    // MARK: - 앱 강제종료
    func systemOff() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
    
    // MARK: - 프로필 등록
    func setCurrentUser(
        image: UIImage?,
        nickname: String,
        gender: Gender,
        age: Int,
        region: Region,
        introduction: String,
        job: Job,
        company: String,
        onSet: @escaping () -> Void
    ) {
        guard let uid = self.userSession?.uid else { return }
        if let image = image {
            ImageUploader.uploadImage(image: image) { imgUrl in
                let data: [String: Any] = [
                    KEY_NICKNAME: nickname,
                    KEY_GENDER: gender.rawValue,
                    KEY_AGE: age,
                    KEY_REGION: region.rawValue,
                    KEY_INTRODUCTION: introduction,
                    KEY_JOB: job.rawValue,
                    KEY_COMPANY: company,
                    KEY_PROFILE_IMAGE_URL: imgUrl,
                    KEY_TIMESTAMP: Timestamp(date: Date()),
                    KEY_BLACK_UIDS: [],
                    KEY_POINT: 100,
                    KEY_IS_PUSH_ON: true,
                    KEY_LAST_POINT_DATE: Timestamp(date: Date(timeInterval: TimeInterval(-3600), since: Date())),
                    KEY_LAST_VISIT_DATE: Timestamp(date: Date())
                ]
                COLLECTION_USERS.document(uid).setData(data) { err in
                    if let err = err {
                        print(err.localizedDescription)
                        return
                    }
                    onSet()
                }
            }
        } else {
            let data: [String: Any] = [
                KEY_NICKNAME: nickname,
                KEY_GENDER: gender.rawValue,
                KEY_AGE: age,
                KEY_REGION: region.rawValue,
                KEY_INTRODUCTION: introduction,
                KEY_JOB: job.rawValue,
                KEY_COMPANY: company,
                KEY_PROFILE_IMAGE_URL: "",
                KEY_TIMESTAMP: Timestamp(date: Date()),
                KEY_BLACK_UIDS: [],
                KEY_POINT: 100,
                KEY_IS_PUSH_ON: true,
                KEY_LAST_POINT_DATE: Timestamp(date: Date(timeInterval: TimeInterval(-3600), since: Date())),
                KEY_LAST_VISIT_DATE: Timestamp(date: Date())
            ]
            COLLECTION_USERS.document(uid).setData(data) { err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                onSet()
            }
        }
    }
    
    // MARK: - 프로필 편집 업데이트
    func updateCurrentUser(
        image: UIImage?,
        nickname: String,
        gender: Gender,
        age: Int,
        region: Region,
        job: Job,
        company: String,
        introduction: String,
        onUpdate: @escaping () -> Void
    ) {
        guard let uid = self.currentUser?.id else { return }
        if let image = image {
            ImageUploader.uploadImage(image: image) { imgUrl in
                let data: [String: Any] = [
                    KEY_PROFILE_IMAGE_URL: imgUrl,
                    KEY_NICKNAME: nickname,
                    KEY_GENDER: gender.rawValue,
                    KEY_AGE: age,
                    KEY_REGION: region.rawValue,
                    KEY_INTRODUCTION: introduction,
                    KEY_JOB: job.rawValue,
                    KEY_COMPANY: company
                ]
                COLLECTION_USERS.document(uid).updateData(data) { err in
                    if let err = err {
                        print(err.localizedDescription)
                        return
                    }
                    self.updateChatRoomProfile(uid: uid, profileImageUrl: imgUrl, nickname: nickname)
                    onUpdate()
                }
            }
            
        } else {
            if let urlString = AuthViewModel.shared.currentUser?.profileImageUrl {
                if !urlString.isEmpty {
                    let ref = Storage.storage().reference(forURL: urlString)
                    ref.delete { err in
                        if let err = err {
                            print(err.localizedDescription)
                        }
                    }
                }
            }
            
            let data: [String: Any] = [
                KEY_PROFILE_IMAGE_URL: "",
                KEY_NICKNAME: nickname,
                KEY_GENDER: gender.rawValue,
                KEY_AGE: age,
                KEY_REGION: region.rawValue,
                KEY_INTRODUCTION: introduction,
                KEY_JOB: job.rawValue,
                KEY_COMPANY: company
            ]
            COLLECTION_USERS.document(uid).updateData(data) { err in
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                self.updateChatRoomProfile(uid: uid, nickname: nickname)
                onUpdate()
            }
        }
    }
    
    // MARK: - 차단하기
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
    
    // MARK: - 인증번호 보내기
    func sendCode(phoneNumber: String, completionHandler: @escaping (_ isSuccess: Bool) -> Void) {
        
        let number = "+82\(phoneNumber)"
        
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { code, err in
            if let err = err {
                print(err.localizedDescription)
                completionHandler(false)
                return
            }
            
            self.verificationId = code ?? ""
            completionHandler(true)
        }
    }
    
    // MARK: - 인증번호 검증하기
    func verifyCode(verificationCode: String, completionHandler: @escaping (_ isSuccess: Bool) -> Void) {
        let credential = PhoneAuthProvider.provider().credential(withVerificationID: self.verificationId, verificationCode: verificationCode)
        Auth.auth().signIn(with: credential) { result, err in
            if let err = err {
                print("Error:: \(err)")
                completionHandler(false)
                return
            }
            
            completionHandler(true)
            
            withAnimation {
                self.userSession = result?.user
                self.fetchUser()
            }
        }
        
    }
    
    // MARK: - 인증번호 재전송 요청
    func requestCode(phoneNumber: String, completionHandler: @escaping (_ isSuccess: Bool) -> Void) {
        
        let number = "+82\(phoneNumber)"
        PhoneAuthProvider.provider().verifyPhoneNumber(number, uiDelegate: nil) { code, err in
            if let err = err {
                completionHandler(false)
                print(err.localizedDescription)
                return
            }
            
            self.verificationId = code ?? ""
            completionHandler(true)
        }
    }
    
    // MARK: - 로그아웃
    func signOut() {
        self.clearSession()
        try? Auth.auth().signOut()
    }
    
    // MARK: - 세션 클리어
    func clearSession() {
        DispatchQueue.main.async {
            self.userSession = nil
            self.currentUser = nil
        }
    }
       
    // MARK: - 회원탈퇴
    func withdrawal(completionHandler: @escaping (_ isSuccess: Bool) -> Void) {
        Task {
            await self.removeData()
            Auth.auth().currentUser?.delete(completion: { err in
                if let err = err {
                    print(err.localizedDescription)
                    completionHandler(false)
                    return
                }
                completionHandler(true)
            })
        }
    }
    
    func removeData() async {
        guard let uid = currentUser?.id else { return }
        
        if let chatSnapshots = try? await COLLECTION_CHATS.whereField(KEY_UIDS, arrayContains: uid).getDocuments() {
            chatSnapshots.documents.forEach { snapshot in
                snapshot.reference.delete()
            }
        }
        
        if let likeCardFromIdSnapshots = try? await COLLECTION_LIKECARDS.whereField(KEY_FROMID, isEqualTo: uid).getDocuments() {
            likeCardFromIdSnapshots.documents.forEach { snapshot in
                snapshot.reference.delete()
            }
        }
        
        if let likeCardToIdSnapshots = try? await COLLECTION_LIKECARDS.whereField(KEY_FROMID, isEqualTo: uid).getDocuments() {
            likeCardToIdSnapshots.documents.forEach { snapshot in
                snapshot.reference.delete()
            }
        }
                
        if let reportSnapshots = try? await COLLECTION_REPORTS.whereField(KEY_FROMID, isEqualTo: uid).getDocuments() {
            reportSnapshots.documents.forEach { snapshot in
                snapshot.reference.delete()
            }
        }
        try? await COLLECTION_POSTS.document(uid).delete()
        try? await COLLECTION_TOKENS.document(uid).delete()
        try? await COLLECTION_USERS.document(uid).delete()
    }
    
    // MARK: - 유저 정보 가져오기
    func fetchUser() {
        guard let uid = userSession?.uid else { return }
        
        COLLECTION_USERS.document(uid).getDocument { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            guard let user = try? snapshot?.data(as: User.self) else {
                return
            }
            self.currentUser = user
            self.updateToken()
        }
    }
    
    // MARK: - 푸쉬알림 토큰 세팅
    private func updateToken() {
        guard let uid = userSession?.uid,
              let token = UserDefaults.standard.string(forKey: "token")
        else {
            return
        }
        
        let data = ["token": token]
        COLLECTION_TOKENS.document(uid).setData(data) { error in
            if let error = error {
                print("DEBUG: 토큰을 세팅하는데 실패했습니다. \(error)")
                return
            }
        }
    }
    
    // MARK: - 푸쉬알림 정보 업데이트
    func updatePushInfo(isPushOn: Bool) {
        guard let uid = userSession?.uid else { return }
        COLLECTION_USERS.document(uid).updateData([
            KEY_IS_PUSH_ON: isPushOn
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
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
