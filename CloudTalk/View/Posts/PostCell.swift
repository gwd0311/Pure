//
//  PostCell.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/02.
//

import SwiftUI
import Firebase
import Kingfisher

struct PostCell: View {
    
    let post: Post
    @ObservedObject var viewModel: PostCellViewModel
    @State private var showDialog = false
    @State private var showAlert = false
    
    init(post: Post, showDialog: Bool = false) {
        self.post = post
        self.viewModel = PostCellViewModel(post: post)
        self.showDialog = showDialog
    }
    
    var body: some View {
        let user = viewModel.user ?? MOCK_USER
        CustomNavigationLink {
            PostDetailView(post: post, viewModel: viewModel)
        } label: {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        CustomNavigationLink {
                            DetailView(user: user)
                        } label: {
                            makeProfileImage(user: user)
                        }
                            .padding(.trailing, 10)
                        VStack(alignment: .leading, spacing: 2) {
                            profileNickname
                            profileDetailInfo
                        }
                    }
                    .padding(.bottom, 12)
                    content
                    postImage
                    heartsAndComments
                }

                .padding(.vertical, 24)
                .padding(.horizontal, 18)
                Rectangle()
                    .foregroundColor(ColorManager.black50)
                    .frame(height: 8)
            }
            .frame(maxWidth: .infinity)
            .background(.white)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("알림"),
                    message: Text("진짜 삭제할거임?"),
                    primaryButton: .destructive(Text("ㅇㅇ"), action: {
                        // TODO: 게시물 삭제 구현
                        viewModel.masterDelete()
                    }),
                    secondaryButton: .cancel(Text("ㄴㄴ"))
                )
            }
        }
    }
    
    @ViewBuilder private func makeDeleteButton() -> some View {
        VStack(spacing: 0) {
            if AuthViewModel.shared.isManager {
                Button(role: .destructive) {
                    self.showAlert.toggle()
                } label: {
                    Text("삭제")
                }
            }
        }
    }
    
    @ViewBuilder private func makeProfileImage(user: User) -> some View {
        VStack {
            if !user.profileImageUrl.isEmpty {
                Color.clear
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        KFImage(URL(string: user.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(width: 42, height: 42)
                    .clipShape(Circle())
                    .contentShape(Circle())
                    .allowsHitTesting(false)
            } else if post.gender == .man {
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
            let user = viewModel.user ?? MOCK_USER
            CustomNavigationLink {
                // 뷰모델에서 user만들어서 가져와야할듯..
                DetailView(user: user)
            } label: {
                Group {
                    Text(user.nickname)
                        .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ColorManager.black600)
                    Text(post.timestamp.dateValue().timeAgoDisplay())
                        .font(.system(size: 13))
                        .foregroundColor(ColorManager.black400)
                }
            }
            Spacer()
            makeDeleteButton()
        }
    }
    private var profileDetailInfo: some View {
        CustomNavigationLink {
            if let user = viewModel.user {
                DetailView(user: user)
            }
        } label: {
            HStack(spacing: 2) {
                Text(post.gender.title)
                    .foregroundColor(post.gender == .man ? ColorManager.blue : ColorManager.pink)
                    .font(.system(size: 12))
                Group {
                    Text("·")
                    Text("\(post.age)살")
                    Text("·")
                    Text(post.region.title)
                }
                .foregroundColor(ColorManager.black400)
                .font(.system(size: 12))
                Spacer()
            }
        }


    }
    
    private var content: some View {
        Text(post.content)
            .multilineTextAlignment(.leading)
            .font(.system(size: 16, weight: .light))
            .padding(.bottom, 14)
    }
    
    private var postImage: some View {
        VStack {
            if !post.postImageUrl.isEmpty {
                Color.clear
                    .aspectRatio(contentMode: .fit)
                    .overlay(
                        KFImage(URL(string: post.postImageUrl))
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(maxWidth: .infinity)
                    .clipShape(Rectangle())
                    .contentShape(Rectangle())
                    .allowsHitTesting(false)
                    .cornerRadius(14)
            }
        }
        .padding(.bottom, 14)
    }
    
    private var heartsAndComments: some View {
        VStack(spacing: 0) {
            HStack(spacing: 4) {
                Group {
                    Text("좋아요")
                    Text(viewModel.heartCount.description)
                    Text("댓글")
                    Text(viewModel.comments.count.description)
                }
                .font(.system(size: 13, weight: .light))
                .foregroundColor(ColorManager.black250)
            }
            .padding(.bottom, 14)
            HStack(spacing: 14) {
                if !viewModel.isHeartPressed {
                    emptyHeartButton
                } else {
                    compactedHeartButton
                }
                Image("comment")
            }
        }
    }
    
    private var emptyHeartButton: some View {
        Button {
            // 빈 하트 클릭
            Task {
                await viewModel.pressEmptyHeartButton(postId: post.uid)
            }
        } label: {
            Image("heart")
        }
    }
    
    private var compactedHeartButton: some View {
        Button {
            // 꽉찬 하트 클릭
            Task {
                await viewModel.pressCompactedHeartButton(postId: post.uid)
            }
        } label: {
            Image("heart_fill")
        }
    }
    
}

struct PostCell_Previews: PreviewProvider {
    static var previews: some View {
        PostCell(post: MOCK_POST)
    }
}
