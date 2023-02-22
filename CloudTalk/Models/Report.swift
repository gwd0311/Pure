//
//  Report.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/16.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Report: Identifiable, Decodable {
    @DocumentID var id: String?
    let fromId: String
    let toId: String
    let reportType: String
    let timestamp: Timestamp
}
