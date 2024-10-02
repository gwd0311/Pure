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
    let onDelete: () -> Void
    @ObservedObject var viewModel: PostCellViewModel
    @State private var showDialog = false
    @State private var showAlert = false
    
    init(post: Post, showDialog: Bool = false, onDelete: @escaping () -> Void) {
        self.post = post
        self.viewModel = PostCellViewModel(post: post)
        self.showDialog = showDialog
        self.onDelete = onDelete
    }
    
    var body: some View {
        VStack {
            if let user = post.user {
                CustomNavigationLink {
                    PostDetailView(
                        post: post,
                        viewModel: viewModel,
                        onDelete: {
                            onDelete()
                        }
                    )
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
                                    makeProfileNickname(user: user)
                                    makeProfileDetailInfo(user: user)
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
        }
    }
    
    // MARK: - 삭제 버튼
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
    
    // MARK: - 프로필 이미지
    @ViewBuilder private func makeProfileImage(user: AppUser) -> some View {
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
    
    // MARK: - 프로필 닉네임
    @ViewBuilder private func makeProfileNickname(user: AppUser) -> some View {
        HStack(spacing: 4) {
            CustomNavigationLink {
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
    
    // MARK: - 프로필 상세정보
    @ViewBuilder private func makeProfileDetailInfo(user: AppUser) -> some View {
        CustomNavigationLink {
            DetailView(user: user)
        } label: {
            PersonalInfoView(
                gender: post.gender,
                age: post.age,
                region: post.region,
                fontSize: 12,
                spacing: 2
            )
        }
    }
    
    // MARK: - Post 내용
    private var content: some View {
        Text(post.content)
            .multilineTextAlignment(.leading)
            .font(.system(size: 16, weight: .light))
            .padding(.bottom, 14)
    }
    
    // MARK: - Post 이미지
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
    
    // MARK: - 하트와 댓글
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
    
    // MARK: - 빈 하트버튼
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
    
    // MARK: - 꽉찬 하트버튼
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

//struct PostCell_Previews: PreviewProvider {
//    static var previews: some View {
//        PostCell(user: <#User#>, post: MOCK_POST)
//    }
//}
