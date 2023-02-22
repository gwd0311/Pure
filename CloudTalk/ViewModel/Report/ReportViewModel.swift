//
//  ReportViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/16.
//

import Foundation
import Firebase

class ReportViewModel: ObservableObject {
    
    func report(user: User, selectedReport: String) {
//        let fromId: String
//        let toId: String
//        let reportType: String
//        let timestamp: Timestamp
        let data: [String: Any] = [
            KEY_FROMID: AuthViewModel.shared.currentUser?.id ?? "",
            KEY_TOID: user.id ?? "",
            KEY_REPORT_TYPE: selectedReport,
            KEY_TIMESTAMP: Timestamp(date: Date())
        ]
        COLLECTION_REPORTS.document().setData(data)
    }
    
}
