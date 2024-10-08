//
//  Token.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/23.
//

import FirebaseFirestore

struct Token: Identifiable, Decodable {
    @DocumentID var id: String?
    let token: String
}
