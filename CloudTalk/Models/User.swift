//
//  User.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/19.
//

import Firebase
import FirebaseFirestoreSwift

struct User: Identifiable, Decodable {
    @DocumentID var id: String?
    var nickname: String
    var gender: String
    var age: String
    var region: String
    var introduction: String
    var profileImageUrl: String
    let timestamp: Timestamp
}
