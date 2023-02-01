//
//  UserCell.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/25.
//

import SwiftUI
import Kingfisher
import Firebase

struct UserCell: View {
    
    let user: User
    
    var body: some View {
        HStack(spacing: 16) {
            Group {
                if !user.profileImageUrl.isEmpty {
                    Color.clear
                        .aspectRatio(contentMode: .fit)
                        .overlay(
                            KFImage(URL(string: user.profileImageUrl))
                                .resizable()
                                .scaledToFill()
                        )
                        .clipShape(Rectangle())
                        .cornerRadius(12)
                } else if user.gender == .man {
                    Image("man")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                } else {
                    Image("woman")
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(12)
                }
            }
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text(user.gender.title)
                        .foregroundColor(user.gender == .man ? ColorManager.blue : ColorManager.pink)
                        .font(.system(size: 13))
                    Group {
                        Text("·")
                        Text("\(user.age)살")
                        Text("·")
                        Text(user.region.title)
                    }
                    .foregroundColor(ColorManager.black400)
                    .font(.system(size: 13))
                    Spacer()
                    if user.timestamp.dateValue().isNew() {
                        Image("new")
                    }
                }
                Text(user.nickname)
                    .foregroundColor(ColorManager.black600)
                    .font(.system(size: 16, weight: .bold))
                Text(user.introduction)
                    .foregroundColor(ColorManager.black400)
                    .font(.system(size: 16))
                    .lineLimit(1)
            }
            .frame(width: UIScreen.main.bounds.width * 0.59)
        }
        .padding(16)
        .background(.white)
        .cornerRadius(14)
    }
}

struct UserCell_Previews: PreviewProvider {
    static var previews: some View {
        UserCell(user: MOCK_USER)
    }
}