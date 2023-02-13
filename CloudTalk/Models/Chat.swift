//
//  Chat.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/06.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Chat: Identifiable, Decodable {
    @DocumentID var id: String?
    let uids: [String]
    let userNickNames: [String: String]
    let userProfileImages: [String: String]
    let userGenders: [String: Gender]
    var lastMessage: String
    var unReadMessageCount: [String: Int]
    let timestamp: Timestamp
}

let MOCK_CHAT = Chat(
    uids: ["87E7wirMMqUc5TBgQMeOCiPqzS83", "778S2JM0kCcGuLmnHYu4yw31nG72"],
    userNickNames: ["87E7wirMMqUc5TBgQMeOCiPqzS83": "하이", "778S2JM0kCcGuLmnHYu4yw31nG72": "헤헤"],
    userProfileImages: [:],
    userGenders: [:],
    lastMessage: "아니 나 잼민이 아니라고 했잖아",
    unReadMessageCount: [:],
    timestamp: Timestamp(date: Date(timeInterval: TimeInterval(-200000), since: Date()))
)
