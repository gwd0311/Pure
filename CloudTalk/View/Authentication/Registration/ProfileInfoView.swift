//
//  ProfileInfoView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/23.
//

import SwiftUI

struct ProfileInfoView: View {
    
    let title: String
    let content: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(.gray)
                .frame(width: 100, alignment: .leading)
                .padding(.leading, 16)
            Text(content)
                .font(.system(size: 15))
            Spacer()
        }
        .frame(height: 50)
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(Color(.systemGray5), lineWidth: 1)
        )
    }
}

struct ProfileInfoView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileInfoView(title: "닉네임", content: "입력")
    }
}
