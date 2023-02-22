//
//  BlackCell.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/21.
//

import SwiftUI
import Kingfisher

struct BlackCell: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @Binding var blackUsers: [User]
    let user: User
    
    var body: some View {
        HStack(spacing: 0) {
            makeProfileImage(user: user)
                .padding(.trailing, 10)
            VStack(alignment: .leading, spacing: 4) {
                makeGenderAgeRegion(user: user)
                Text(user.nickname.components(separatedBy: " ").joined().isEmpty ? "닉네임로드오류" : user.nickname)
                    .foregroundColor(ColorManager.black600)
                    .font(.system(size: 16, weight: .bold))
            }
            .frame(width: UIScreen.main.bounds.width * 0.59)
            Button {
                // TODO: 차단 해제
                authViewModel.unBlock(uid: user.id ?? "", onUnBlock: {
                    withAnimation {
                        blackUsers.removeAll(where: { $0.id == user.id ?? ""})
                    }
                })
            } label: {
                VStack {
                    Text("해제")
                        .foregroundColor(ColorManager.black600)
                        .font(.system(size: 12))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                }
                .frame(width: 46, height: 30)
                .overlay(
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 1)
                        .foregroundColor(ColorManager.black150)
                )
            }
        }
        .padding(16)
        .frame(height: 72)
        .background(.white)
        .cornerRadius(22)
    }
    
    
    
    // MARK: - 성별, 나이, 지역
    @ViewBuilder private func makeGenderAgeRegion(user: User) -> some View {
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
        }
    }
    
    // MARK: - 프로필 이미지
    @ViewBuilder private func makeProfileImage(user: User) -> some View {
        Group {
            if !user.profileImageUrl.isEmpty {
                Color.clear
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        KFImage(URL(string: user.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .contentShape(Circle())
            } else if user.gender == .man {
                Image("man")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .contentShape(Circle())
            } else {
                Image("woman")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 44, height: 44)
                    .clipShape(Circle())
                    .contentShape(Circle())
            }
        }
    }
}

struct BlackCell_Previews: PreviewProvider {
    static var previews: some View {
        BlackCell(blackUsers: .constant([MOCK_USER]), user: MOCK_USER)
    }
}
