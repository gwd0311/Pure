//
//  ProfileInputButton.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/03/01.
//

import SwiftUI

struct ProfileInputButton: View {
    
    let title: String
    let content: String
    let isOptional: Bool
    let onClick: () -> Void
    
    init(title: String, content: String, isOptional: Bool = false, onClick: @escaping () -> Void) {
        self.title = title
        self.content = content
        self.isOptional = isOptional
        self.onClick = onClick
    }
    
    var body: some View {
        Button {
            onClick()
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(title)
                    if isOptional {
                        Text("(선택)")
                            .foregroundColor(ColorManager.black200)
                            .padding(.leading, 2)
                    }
                    Spacer()
                    Text(content.components(separatedBy: " ").joined().isEmpty ? "입력해주세요" : content)
                        .foregroundColor(content.components(separatedBy: " ").joined().isEmpty ? ColorManager.black200 : ColorManager.black600)
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(ColorManager.black30)
            .cornerRadius(14)
            .padding(.horizontal, 18)
            .padding(.bottom, 10)
        }
        .tint(.black)
    }
}

struct ProfileInputButton_Previews: PreviewProvider {
    static var previews: some View {
        ProfileInputButton(
            title: "닉네임",
            content: "",
            isOptional: true,
            onClick: {}
        )
    }
}
