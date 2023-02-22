//
//  SelectableModal.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/16.
//

import SwiftUI

struct SelectableModal: View {
    
    let title: String
    let selectCases: [String]
    let onSelect: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 26)
            Text(title)
                .font(.system(size: 17, weight: .bold))
                .padding(.bottom, 16)
            Rectangle()
                .foregroundColor(ColorManager.black150)
                .frame(height: 1)
            ForEach(selectCases, id: \.self) { selectCase in
                Button {
                    onSelect(selectCase)
                } label: {
                    VStack(spacing: 0) {
                        Rectangle()
                            .foregroundColor(ColorManager.black50)
                            .frame(height: 1)
                        Spacer()
                        Text(selectCase)
                            .foregroundColor(ColorManager.black600)
                            .font(.system(size: 16))
                        Spacer()
                    }
                    .frame(height: 52)
                }
            }
        }
        .frame(width: 310)
        .background(.white)
        .cornerRadius(24)
    }
}

struct SelectableModal_Previews: PreviewProvider {
    static var previews: some View {
        SelectableModal(
            title: "신고 사유를 선택해주세요",
            selectCases: ["불쾌한 사진", "허위 프로필", "사진 도용", "욕설 및 비방", "불법촬영물 공유", "기타"],
            onSelect: { _ in }
        )
    }
}
