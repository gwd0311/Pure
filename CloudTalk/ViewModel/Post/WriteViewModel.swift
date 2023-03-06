//
//  WriteViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/02.
//

import SwiftUI
import Firebase
import FirebaseFirestoreSwift
import FirebaseStorage

@MainActor
class WriteViewModel: ObservableObject {
    
    let placeholderText = "당신을 알릴 수 있는 글을 작성해주세요.\n\nSNS 아이디 또는 개인 연락처를 노출할 경우\n글이 삭제됩니다.\n\n부적절한 사진 또는 내용 등록 시\n이용 제한 될 수 있습니다.\n\n사진은 한장만 업로드 가능하며,\n새로운 글 작성 시 기존 글은 삭제됩니다."
    
    // TODO: viewModel에서 50포인트 올리기 + lastPointDate update하기
    func getPoint(onGet: @escaping () -> Void) {
        let authViewModel = AuthViewModel.shared
        guard let user = authViewModel.currentUser else { return }
        guard let uid = user.id else { return }
        
        COLLECTION_USERS.document(uid).updateData([
            KEY_LAST_POINT_DATE: Timestamp(date: Date()),
            KEY_POINT: FieldValue.increment(Int64(50))
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            onGet()
        }
    }
    
    func register(image: UIImage?, text: String) async {
        let authViewModel = AuthViewModel.shared
        guard let user = authViewModel.currentUser else { return }
        guard let uid = user.id else { return }
        
        let data: [String: Any] = [
            KEY_UID: uid,
            KEY_NICKNAME: user.nickname,
            KEY_GENDER: user.gender.rawValue,
            KEY_AGE: user.age,
            KEY_REGION: user.region.rawValue,
            KEY_CONTENT: text,
            KEY_LIKE_COUNT: 0,
            KEY_LIKE_UIDS: [],
            KEY_COMMENT_COUNT: 0,
            KEY_PROFILE_IMAGE_URL: user.profileImageUrl,
            KEY_POST_IMAGE_URL: "",
            KEY_TIMESTAMP: Timestamp(date: Date())
        ]
        
        await deleteCurrentImage(uid: uid)

        await uploadNewImage(uid: uid, data: data, image: image)
        
    }
    
    private func uploadNewImage(uid: String, data: [String: Any], image: UIImage?) async {
        try? await COLLECTION_POSTS.document(uid).delete()
        guard let snapShot = try? await COLLECTION_POSTS.document(uid).collection("comments").getDocuments() else { return }
        for document in snapShot.documents {
            try? await document.reference.delete()
        }
        try? await COLLECTION_POSTS.document(uid).setData(data)
        
        if let image = image {
            ImageUploader.uploadImage(image: image) { imageUrl in
                let data = [KEY_POST_IMAGE_URL: imageUrl]
                COLLECTION_POSTS.document(uid).updateData(data) { _ in
                    print("이미지 업로드 성공!")
                }
            }
        } else {
            print("이미지 사용 안함")
        }
    }
    
    private func deleteCurrentImage(uid: String) async {
        let doc = try? await COLLECTION_POSTS.document(uid).getDocument()
            
        guard let post = try? doc?.data(as: Post.self) else { return }
            
        if !post.postImageUrl.isEmpty {
            let ref = Storage.storage().reference(forURL: post.postImageUrl)
            
            ref.delete { err in
                if let err = err {
                    print("Error:: \(err)")
                    return
                }
                print("기존 사진 삭제 성공!!")
            }
        } else {
            print("기존 사진 없음")
        }
            
    }
    
}
