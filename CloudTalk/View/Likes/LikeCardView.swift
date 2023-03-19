//
//  LikeCardView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/15.
//

import SwiftUI

struct LikeCardView: View {
    
    let user: User
    
    var body: some View {
                
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
                PersonalInfoView(
                    gender: user.gender,
                    age: user.age,
                    region: user.region,
                    fontSize: 13,
                    spacing: 2
                )
            }
            .padding(.horizontal, 30)
            .padding(.vertical, 20)
        }
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(lineWidth: 2)
                .foregroundColor(ColorManager.black100)
        )
    }
}

//struct LikeCardView_Previews: PreviewProvider {
//    static var previews: some View {
//        LikeCardView(likeCard: MOCK_LIKECARD)
//    }
//}
