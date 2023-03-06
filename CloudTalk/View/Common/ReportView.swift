//
//  ReportView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/16.
//

import SwiftUI

enum ReportType: String, CaseIterable {
    case nastyPicture = "불쾌한 사진"
    case fakeProfile = "허위 프로필"
    case photoTheft = "사진 도용"
    case abuse = "욕설 및 비방"
    case abuseRecordings = "불법 촬영물 공유"
}

struct ReportView: View {
    
    @ObservedObject var viewModel = ReportViewModel()
    let uid: String
    @Binding var showReportView: Bool
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture {
                    showReportView = false
                }
            SelectableModal(
                title: "신고 사유를 입력해주세요",
                selectCases: ReportType.allCases.compactMap({  $0.rawValue})
            ) { selectedReport in
                // TODO: 뷰모델에서 report 하기
                viewModel.report(uid: self.uid, selectedReport: selectedReport)
                withAnimation {
                    showAlert.toggle()
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("신고 완료"),
                    message: Text("신고가 접수되었습니다."),
                    dismissButton: .default(Text("확인"), action: {
                        showReportView = false
                    })
                )
        }
        }
    }
}

struct ReportView_Previews: PreviewProvider {
    static var previews: some View {
        ReportView(uid: "", showReportView: .constant(true))
    }
}
