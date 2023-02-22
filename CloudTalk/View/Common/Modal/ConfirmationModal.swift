//
//  ConfirmationModal.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/16.
//

import SwiftUI

struct ConfirmationModal: View {
    
    let title: String
    let content: String
    let confirmationTitle: String
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 26)
            Image("info")
                .padding(.bottom, 16)
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .padding(.bottom, 8)
            Text(content)
                .font(.system(size: 14, weight: .light))
                .foregroundColor(ColorManager.black300)
                .padding(.bottom, 16)
            HStack(spacing: 6) {
                Button {
                    onCancel()
                } label: {
                    Text("취소")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ColorManager.black400)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 52)
                        .background(ColorManager.black100)
                        .cornerRadius(12)
                        .frame(width: 134, height: 48)
                }

                Button {
                    onConfirm()
                } label: {
                    Text(confirmationTitle)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.vertical, 14)
                        .padding(.horizontal, 38)
                        .background(ColorManager.red)
                        .cornerRadius(12)
                        .frame(width: 134, height: 48)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
        }
        .frame(width: 310)
        .background(.white)
        .cornerRadius(24)
    }
}

struct ConfirmationModal_Previews: PreviewProvider {
    static var previews: some View {
        ConfirmationModal(
            title: "구름톡 탈퇴하기",
            content: "탈퇴 시 모든 정보가 사라집니다.",
            confirmationTitle: "탈퇴하기",
            onConfirm: {},
            onCancel: {}
        )
    }
}
