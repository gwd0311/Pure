//
//  LikeCardView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/15.
//

import SwiftUI

struct LikeCardView: View {
    
    let likeCard: LikeCard
    
    var body: some View {
        
        let user = likeCard.user ?? MOCK_USER
        
        VStack {
            VStack(alignment: .center, spacing: 0) {
                ProfileImageView(
                    profileImageUrl: user.profileImageUrl,
                    gender: user.gender,
                    type: .circle,
                    width: 98,
                    height: 98
                )
                .padding(.bottom, 10)
                Text(user.nickname)
                    .foregroundColor(.black)
                    .font(.system(size: 16, weight: .semibold))
                    .padding(.bottom, 4)
                HStack(spacing: 2) {
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
                }
            }
            .padding(.horizontal, 35)
            .padding(.vertical, 20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 2)
                .foregroundColor(ColorManager.black100)
        )
    }
}

struct LikeCardView_Previews: PreviewProvider {
    static var previews: some View {
        LikeCardView(likeCard: MOCK_LIKECARD)
    }
}
