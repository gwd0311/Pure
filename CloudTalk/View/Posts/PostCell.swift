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
    
    init(post: Post, showDialog: Bool = false) {
        self.post = post
        self.viewModel = PostCellViewModel(post: post)
        self.showDialog = showDialog
    }
    
    var body: some View {
        CustomNavigationLink {
            PostDetailView(post: post, viewModel: viewModel)
        } label: {
            VStack(spacing: 0) {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(spacing: 0) {
                        CustomNavigationLink {
                            if let user = viewModel.user {
                                DetailView(user: user)
                            }
                        } label: {
                            profileImage
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
            .confirmationDialog("Select", isPresented: $showDialog) {
                let uid = AuthViewModel.shared.currentUser?.id
                Button("신고하기") {
                    // uid 넘겨줘서 신고페이지로 ㄱㄱ
                    
                }
                Button("차단하기") {
                    
                }
                if post.uid == (uid ?? "") {
                    Button("삭제하기", role: .destructive) {
                        
                    }
                }
            }
        }
    }
    
    private var profileImage: some View {
        VStack {
            if !post.profileImageUrl.isEmpty {
                Color.clear
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        KFImage(URL(string: post.profileImageUrl))
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
            CustomNavigationLink {
                // 뷰모델에서 user만들어서 가져와야할듯..
                if let user = viewModel.user {
                    DetailView(user: user)
                }
            } label: {
                Group {
                    Text(post.nickname)
                        .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ColorManager.black600)
                    Text(post.timestamp.dateValue().timeAgoDisplay())
                        .font(.system(size: 13))
                        .foregroundColor(ColorManager.black400)
                }
            }
            Spacer()
            Button {
                // 더보기 기능 구현
                DispatchQueue.main.async {
                    showDialog.toggle()
                    print(showDialog)
                }
            } label: {
                Image("more")
            }
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
                    Text(post.commentCount.description)
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
