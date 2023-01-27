//
//  RegistrationViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/20.
//

import SwiftUI
import Firebase

@MainActor
class RegistrationViewModel: ObservableObject {
    
    @Published var image: UIImage?
    @Published var nickname: String?
    @Published var gender: Gender?
    @Published var age: String?
    @Published var region: Region?
    @Published var introduction: String?
    @Published var showSheet = false
    @Published var isLoading = false
    
    private var isComplete: Bool {
        if nickname != nil && gender != nil && age != nil && region != nil && introduction != nil {
            return true
        } else {
            return false
        }
    }
    
    // ["서울", "대전", "대구", "부산", "인천", "광주", "울산", "세종", "경기", "강원", "충북", "충남", "전북", "전남", "경북", "경남", "제주", "외국"]
    
    func setNickName(nickname: String) {
        self.showSheet = false
        self.nickname = nickname
    }
    
    func setGender(selectedIndex: Int) {
        self.showSheet = false
        switch selectedIndex {
        case 1:
            self.gender = .man
        case 2:
            self.gender = .woman
        default:
            break
        }
    }
    
    func setAge(selectedIndex: Int) {
        self.showSheet = false
        self.age = String(selectedIndex)
    }
    
    func setRegion(selectedIndex: Int) {
        self.showSheet = false
        self.region = Region.allCases[selectedIndex]
    }
    
    func setIntroduction(introduction: String) {
        self.showSheet = false
        self.introduction = introduction
    }
    
    func register(completion: @escaping () -> Void) {
                
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        guard let nickname = nickname,
              let gender = gender,
              let age = age,
              let region = region,
              let introduction = introduction else {
            print("입력이 안되었습니다.")
            return
        }
        
        let data: [String: Any] = [
            KEY_NICKNAME: nickname,
            KEY_GENDER: gender.rawValue,
            KEY_AGE: age,
            KEY_REGION: region.rawValue,
            KEY_INTRODUCTION: introduction,
            KEY_PROFILE_IMAGE_URL: "",
            KEY_TIMESTAMP: Timestamp(date: Date())
        ]
        
        COLLECTION_USERS.document(uid).setData(data) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            if let image = self.image {
                ImageUploader.uploadImage(image: image) { imageUrl in
                    let data = [KEY_PROFILE_IMAGE_URL: imageUrl]
                    COLLECTION_USERS.document(uid).updateData(data) { _ in
                        print("이미지 업로드 성공")
                    }
                }
            } else {
                let data = [KEY_PROFILE_IMAGE_URL: ""]
                COLLECTION_USERS.document(uid).updateData(data) { _ in
                    print("이미지 사용 안함")
                }
            }
            
            print("등록에 성공했습니다.")
            completion()
        }

    }
    
}
