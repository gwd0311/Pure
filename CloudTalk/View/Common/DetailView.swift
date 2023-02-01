//
//  DetailView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/31.
//

import SwiftUI
import Kingfisher

struct DetailView: View {
    
    let user: User
    
    @State private var showDialog = false
    
    var body: some View {
        VStack(alignment: .leading) {

            imageSection
            upperContent
            lowerContent
            
            Spacer()
            
            bottomContent
        }
        .confirmationDialog("Select", isPresented: $showDialog, actions: {
            Button {
                // 차단하기 기능 구현
                
            } label: {
                Text("차단하기")
            }
            Button {
                // 신고하기 기능 구현
                
            } label: {
                Text("신고하기")
            }
        })
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Menu {

                } label: {
                    Image("more")
                }
            }
        }
        .navigationTitle(user.nickname)
        .navigationBarTitleDisplayMode(.inline)
        .customNavBarItems(trailing: moreButton)
        .customNavigationTitle(user.nickname)
    }
    
    private var imageSection: some View {
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
                    .contentShape(Rectangle())
            } else if user.gender == .man {
                Image("man")
                    .resizable()
                    .scaledToFit()
            } else {
                Image("woman")
                    .resizable()
                    .scaledToFit()
            }
        }
        .padding(.bottom, 24)
    }
    
    private var upperContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Text(user.nickname)
                    .font(.system(size: 22, weight: .bold))
                .padding(.bottom, 10)
                Spacer()
                if user.timestamp.dateValue().isNew() {
                    Image("new")
                    .padding(.bottom)
                }
            }
            HStack(spacing: 4) {
                Text(user.gender == .man ? "남자" : "여자")
                    .foregroundColor(user.gender == .man ? ColorManager.blue : ColorManager.pink)
                    .font(.system(size: 14))
                Group {
                    Text("·")
                    Text("\(user.age)살")
                    Text("·")
                    Text(user.region.title)
                }
                .foregroundColor(ColorManager.black400)
                .font(.system(size: 14))
                Spacer()
            }
            .padding(.bottom, 20)
            Divider()
        }
        .padding(.horizontal, 18)
        .padding(.bottom, 20)
    }
    
    private var lowerContent: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("내 소개")
                .font(.system(size: 16, weight: .bold))
                .padding(.bottom, 10)
            Text(user.introduction)
                .font(.system(size: 16))
                .foregroundColor(ColorManager.black400)
        }
        .padding(.horizontal, 18)
    }
    
    private var bottomContent: some View {
        HStack {
            Button {
                // 좋아요 기능 구현
                
            } label: {
                VStack(spacing: 0) {
                    Image("heart")
                    Text("좋아요")
                        .foregroundColor(ColorManager.redLight)
                        .font(.system(size: 11, weight: .semibold))
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 17)
            Button {
                // 메시지 전송 기능 구현
                
            } label: {
                Text("메시지 전송")
            }
            .buttonStyle(MainButtonStyle(color: ColorManager.blue))

        }
        .padding(.horizontal, 18)
        .padding(.vertical, 8)
    }
    
    private var moreButton: some View {
        Button {
            // 신고하기 차단하기 기능 fabula dialog로 구현해보기
            showDialog.toggle()
        } label: {
            Image("more")
        }
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(user: MOCK_USER)
    }
}
