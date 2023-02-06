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
    let lastMessage: String
    let unReadMessageCount: Int
    let timestamp: Timestamp
}

let MOCK_CHAT = Chat(
    uids: ["87E7wirMMqUc5TBgQMeOCiPqzS83", "778S2JM0kCcGuLmnHYu4yw31nG72"],
    lastMessage: "아니 나 잼민이 아니라고 했잖아",
    unReadMessageCount: 4,
    timestamp: Timestamp(date: Date(timeInterval: TimeInterval(-200000), since: Date()))
)
