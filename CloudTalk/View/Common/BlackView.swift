//
//  BlackView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/16.
//

import SwiftUI

struct BlackView: View {
    
    let uid: String
    @Binding var showBlackView: Bool
    @State private var showAlert = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.5).ignoresSafeArea()
                .onTapGesture {
                    self.showBlackView = false
                }
            ConfirmationModal(
                title: "차단하기",
                content: "차단한 회원의 모든 정보가 가려집니다.",
                confirmationTitle: "차단하기",
                onConfirm: {
                    AuthViewModel.shared.blackUser(uid: self.uid, completion: {
                        self.showAlert.toggle()
                        print(AuthViewModel.shared.blackUids)
                    })
                },
                onCancel: {
                    self.showBlackView = false
                }
            )
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("차단 완료"),
                    message: Text("차단이 완료되었습니다."),
                    dismissButton: .default(Text("확인"), action: {
                        self.showBlackView = false
                        dismiss()
                    })
                )
            }
        }
    }
}

struct BlackView_Previews: PreviewProvider {
    static var previews: some View {
        BlackView(uid: "", showBlackView: .constant(true))
    }
}
