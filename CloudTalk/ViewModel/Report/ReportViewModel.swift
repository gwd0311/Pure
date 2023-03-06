//
//  ReportViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/16.
//

import Foundation
import Firebase

class ReportViewModel: ObservableObject {
    
    func report(uid: String, selectedReport: String) {

        let data: [String: Any] = [
            KEY_FROMID: AuthViewModel.shared.currentUser?.id ?? "",
            KEY_TOID: uid,
            KEY_REPORT_TYPE: selectedReport,
            KEY_TIMESTAMP: Timestamp(date: Date())
        ]
        COLLECTION_REPORTS.document().setData(data)
    }
    
}
