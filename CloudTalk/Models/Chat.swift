//
//  Chat.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/06.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Chat: Identifiable, Decodable, Sequence {
    @DocumentID var id: String?
    let uids: [String]
    let userNickNames: [String: String]
    let userAges: [String: Int]
    let userProfileImages: [String: String]
    let userGenders: [String: Gender]
    var lastMessage: String
    var unReadMessageCount: [String: Int]
    let timestamp: Timestamp
    
    func makeIterator() -> AnyIterator<Chat> {
        let properties: [Chat] = [self]
        var index = 0
        return AnyIterator {
            guard index < properties.count else { return nil }
            let property = properties[index]
            index += 1
            return property
        }
    }
}

let MOCK_CHAT = Chat(
    uids: ["87E7wirMMqUc5TBgQMeOCiPqzS83", "778S2JM0kCcGuLmnHYu4yw31nG72"],
    userNickNames: ["87E7wirMMqUc5TBgQMeOCiPqzS83": "하이", "778S2JM0kCcGuLmnHYu4yw31nG72": "헤헤"],
    userAges: [:],
    userProfileImages: [:],
    userGenders: [:],
    lastMessage: "채팅 메시지 오류",
    unReadMessageCount: [:],
    timestamp: Timestamp(date: Date(timeInterval: TimeInterval(-200000), since: Date()))
)
