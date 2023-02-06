//
//  PostDetailView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/03.
//

import SwiftUI
import Kingfisher

struct PostDetailView: View {
    
    let post: Post
    @ObservedObject var viewModel: PostCellViewModel
    @State private var showDialog = false
    @State private var text = ""
    @State private var isLoading = false
    
    var body: some View {
        ScrollViewReader { proxy in
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HStack(spacing: 0) {
                            profileImage
                                .padding(.trailing, 10)
                            VStack(alignment: .leading, spacing: 2) {
                                profileNickname
                                profileDetailInfo
                            }
                        }
                        .padding(.bottom, 8)
                        Text(post.timestamp.dateValue().formatYmd())
                            .foregroundColor(ColorManager.black250)
                            .font(.system(size: 13, weight: .light))
                            .padding(.bottom, 20)
                        dividerLine
                            .padding(.bottom, 20)
                        
                        content
                        postImage
                    }
                    .padding(.top, 24)
                    .padding(.horizontal, 18)
                    .padding(.bottom, 40)
                    
                    dividerLine
                        .padding(.bottom, 14)
                    heartAndComment
                    dividerLine
                    commentSection
                }
                .refreshable {
                    await viewModel.refresh()
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
                    if post.id == (uid ?? "") {
                        Button("삭제하기", role: .destructive) {
                            
                        }
                    }
                }
                
                commentInputSection(proxy: proxy)
            }
            .onWillAppear {
                Task { @MainActor in
                    await self.viewModel.fetchComments()
                }
            }
            .overlay(
                isLoading ? LoadingView() : nil
            )
        .customNavBarItems(trailing: moreButton)
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
            Text(post.nickname)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(ColorManager.black600)
            Spacer()
        }
    }
    private var profileDetailInfo: some View {
        HStack(spacing: 2) {
            Text(post.gender.title)
                .foregroundColor(post.gender == .man ? ColorManager.blue : ColorManager.pink)
                .font(.system(size: 13))
            Group {
                Text("·")
                Text("\(post.age)살")
                Text("·")
                Text(post.region.title)
            }
            .foregroundColor(ColorManager.black400)
            .font(.system(size: 13))
            Spacer()
        }
    }
    
    private var content: some View {
        Text(post.content)
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
    
    private var heartAndComment: some View {
        HStack(spacing: 0) {
            Spacer()
            Button {
                // 하트 누르기
                Task {
                    if viewModel.isHeartPressed {
                        await viewModel.pressCompactedHeartButton(postId: post.uid)
                    } else {
                        await viewModel.pressEmptyHeartButton(postId: post.uid)
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(self.viewModel.isHeartPressed ? "heart_fill" : "heart")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                    Text("\(self.viewModel.heartCount)개")
                        .foregroundColor(ColorManager.red)
                        .font(.system(size: 14, weight: .bold))
                }
                .tint(.black)
            }
            Spacer()
            Rectangle()
                .frame(width: 1, height: 32)
                .foregroundColor(ColorManager.black50)
            Spacer()
            HStack(spacing: 0) {
                Text("댓글 \(viewModel.comments.count)개")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(ColorManager.black400)
            }
            Spacer()
        }
        .padding(.bottom, 14)
    }
    
    private var moreButton: some View {
        Button {
            // 더보기 기능 구현
            DispatchQueue.main.async {
                hideKeyboard()
                showDialog.toggle()
            }
        } label: {
            Image("more")
        }
    }
    
    private var dividerLine: some View {
        Rectangle()
            .frame(height: 1)
            .foregroundColor(ColorManager.black50)
    }
    
    private var commentSection: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.comments) { comment in
                CommentView(comment: comment)
                    .background(comment.uid == post.uid ? ColorManager.black30 : nil)
                    .id(comment.id)
            }
        }
    }
    
    @ViewBuilder private func commentInputSection(proxy: ScrollViewProxy) -> some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(ColorManager.black50)
                .frame(height: 1)
            HStack(spacing: 0) {
                TextField("댓글을 입력해주세요.", text: $text)
                Spacer()
                Button {
                    // 댓글 등록하기
                    Task {
                        isLoading = true
                        await viewModel.registerComment(text: text)
                        self.text = ""
                        proxy.scrollTo(viewModel.comments.last?.id)
                        hideKeyboard()
                        isLoading = false
                    }
                } label: {
                    if text.isEmpty {
                        Image("sendBtn_off")
                    } else {
                        Image("sendBtn_on")
                    }
                }
                .disabled(text.isEmpty)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
    }
    
}


struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView(post: MOCK_POST, viewModel: PostCellViewModel(post: MOCK_POST))
    }
}
