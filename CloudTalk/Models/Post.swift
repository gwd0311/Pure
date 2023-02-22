//
//  Post.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/01.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Post: Identifiable, Decodable {
    @DocumentID var id: String?
    let uid: String
    let nickname: String
    let gender: Gender
    let age: Int
    let region: Region
    let content: String
    let likeUids: [String]
    let profileImageUrl: String
    let postImageUrl: String
    let timestamp: Timestamp
}

let MOCK_POST = Post(
    uid: "RxuVbZB5zwakO64K5bbBoFFIuTn1",
    nickname: "닉네임 오류",
    gender: .woman,
    age: 1,
    region: .busan,
    content: "게시글을 불러오지 못했습니다.",
    likeUids: ["RxuVbZB5zwakO64K5bbBoFFIuTn1"],
    profileImageUrl: "",
    postImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/fluttergram-faa5e.appspot.com/o/profile_images%2F0C12D688-F9F1-4EDE-B7B4-F3F506748685?alt=media&token=063127b5-713c-46d9-9d0d-86450e751569",
    timestamp: Timestamp(date: Date(timeInterval: TimeInterval(-200000), since: Date()))
)
