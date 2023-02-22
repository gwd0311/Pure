//
//  LikeCard.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/15.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct LikeCard: Identifiable, Decodable {
    @DocumentID var id: String?
    let fromId: String
    let toId: String
    let timestamp: Timestamp
    var user: User?
}

let MOCK_LIKECARD = LikeCard(
    fromId: "",
    toId: "",
    timestamp: Timestamp(date: Date(timeInterval: TimeInterval(-200000), since: Date()))
)
