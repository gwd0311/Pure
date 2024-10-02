//
//  BannedUser.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/03/03.
//

import Foundation
import FirebaseFirestore

struct BannedUser: Identifiable, Decodable {
    @DocumentID var id: String?
    let uid: String
}
