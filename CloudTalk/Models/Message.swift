//
//  Message.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Message: Identifiable, Decodable {
    @DocumentID var id: String?
    let fromId: String
    let toId: String
    let isRead: Bool
    let text: String
    let timestamp: Timestamp
}

let MOCK_MESSAGE = Message(
    fromId: "778S2JM0kCcGuLmnHYu4yw31nG72",
    toId: "87E7wirMMqUc5TBgQMeOCiPqzS83",
    isRead: false,
    text: "나와 놀게",
    timestamp: Timestamp(date: Date(timeInterval: TimeInterval(-200000), since: Date()))
)
