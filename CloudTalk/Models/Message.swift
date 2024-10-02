//
//  Message.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import Foundation
import FirebaseFirestore

struct Message: Identifiable, Decodable, Equatable {
    @DocumentID var id: String?
    let cid: String
    let fromId: String
    let toId: String
    let text: String
    let timestamp: Timestamp
    
    var date: Date {
        timestamp.dateValue()
    }
}

let MOCK_MESSAGE = Message(
    cid: "",
    fromId: "778S2JM0kCcGuLmnHYu4yw31nG72",
    toId: "87E7wirMMqUc5TBgQMeOCiPqzS83",
    text: "메시지 오류",
    timestamp: Timestamp(date: Date(timeInterval: TimeInterval(-200000), since: Date()))
)
