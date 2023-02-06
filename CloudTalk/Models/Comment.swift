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
    let uid: String
    let comment: String
    let nickname: String
    let gender: Gender
    let profileImageUrl: String
    let timestamp: Timestamp
}

let MOCK_COMMENT = Comment(
    uid: "RxuVbZB5zwakO64K5bbBoFFIuTn1",
    comment: "신기하게 생기셨네요",
    nickname: "쎈맹이",
    gender: .woman,
    profileImageUrl: "https://firebasestorage.googleapis.com:443/v0/b/fluttergram-faa5e.appspot.com/o/profile_images%2F45AE4D61-328A-405B-B4BC-5101A9A59FF2?alt=media&token=a7cc14be-9122-42da-bca9-134a42220794",
    timestamp: Timestamp(date: Date(timeInterval: TimeInterval(-200000), since: Date()))
)
