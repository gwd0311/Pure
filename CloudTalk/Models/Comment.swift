//
//  Comment.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/03.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Comment: Identifiable, Decodable {
    @DocumentID var id: String?
    let pid: String
    let uid: String
    let comment: String
    let nickname: String
    let gender: Gender
    let profileImageUrl: String
    let timestamp: Timestamp
    var user: User?
}

let MOCK_COMMENT = Comment(
    pid: "JQEckXnvXfP2WwSyZ6aLROMGNEe2",
    uid: "RxuVbZB5zwakO64K5bbBoFFIuTn1",
    comment: "댓글 로드 오류",
    nickname: "닉네임 오류",
    gender: .woman,
    profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/fluttergram-faa5e.appspot.com/o/profile_images%2F45AE4D61-328A-405B-B4BC-5101A9A59FF2?alt=media&token=a7cc14be-9122-42da-bca9-134a42220794",
    timestamp: Timestamp(date: Date(timeInterval: TimeInterval(-200000), since: Date()))
)
