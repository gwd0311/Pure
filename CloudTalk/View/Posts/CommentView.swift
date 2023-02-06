//
//  CommentView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/03.
//

import SwiftUI
import Kingfisher

struct CommentView: View {
    
    let comment: Comment
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    profileImage
                        .padding(.trailing, 10)
                    VStack(alignment: .leading, spacing: 2) {
                        profileNickname
                        Text(comment.comment)
                            .foregroundColor(ColorManager.black600)
                            .font(.system(size: 14))
                    }
                }
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 20)
            Rectangle()
                .frame(height: 1)
                .foregroundColor(ColorManager.black50)
        }
    }
    
    private var profileImage: some View {
        VStack {
            if !comment.profileImageUrl.isEmpty {
                Color.clear
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        KFImage(URL(string: comment.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .allowsHitTesting(false)
            } else if comment.gender == .man {
                Image("man")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .allowsHitTesting(false)
            } else {
                Image("woman")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .allowsHitTesting(false)
            }
        }
    }
    
    private var profileNickname: some View {
        HStack(spacing: 4) {
            Text(comment.nickname)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(ColorManager.black600)
            Text("·")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(ColorManager.black400)
            Text(comment.timestamp.dateValue().timeAgoDisplay())
                .font(.system(size: 12))
                .foregroundColor(ColorManager.black400)
            Spacer()
            if comment.uid == AuthViewModel.shared.currentUser?.id {
                Button {
                    
                } label: {
                    Text("삭제")
                        .font(.system(size: 12))
                }
            } else {
                Button {
                    
                } label: {
                    Text("신고")
                        .font(.system(size: 12))
                }
            }
        }
        .tint(ColorManager.black250)
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(comment: MOCK_COMMENT)
    }
}
