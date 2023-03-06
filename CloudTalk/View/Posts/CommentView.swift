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
    let onDelete: () -> Void
    @ObservedObject var viewModel: CommentViewModel
    @State private var showMasterDeleteAlert = false
    @State private var showDeleteAlert = false
    
    init(comment: Comment, onDelete: @escaping () -> Void) {
        self.comment = comment
        self.onDelete = onDelete
        self.viewModel = CommentViewModel(comment: comment)
    }
    
    var body: some View {
        let user = viewModel.user ?? MOCK_USER
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 0) {
                    CustomNavigationLink {
                        NavigationLazyView(DetailView(user: user))
                    } label: {
                        makeProfileImage(user: user)
                            .padding(.trailing, 10)
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        makeNickname(user: user)
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
            VStack{
                Text("")
                    .alert(isPresented: $showMasterDeleteAlert) {
                        Alert(
                            title: Text("알림"),
                            message: Text("정말 삭제하시겠습니까?"),
                            primaryButton: .destructive(Text("예"), action: {
                                viewModel.masterDelete {
                                    onDelete()
                                }
                            }),
                            secondaryButton: .cancel(Text("아니오"))
                        )
                    }
                Text("")
                    .alert(isPresented: $showDeleteAlert) {
                        Alert(
                            title: Text("알림"),
                            message: Text("정말 댓글을 삭제하시겠습니까?"),
                            primaryButton: .destructive(Text("예"), action: {
                                viewModel.delete {
                                    onDelete()
                                }
                            }),
                            secondaryButton: .cancel(Text("아니오"))
                        )
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
            } else if user.gender == .man {
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
    
    @ViewBuilder private func makeNickname(user: User) -> some View {
        HStack(spacing: 4) {
            Text(user.nickname)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(ColorManager.black600)
            Text("·")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(ColorManager.black400)
            Text(comment.timestamp.dateValue().timeAgoDisplay())
                .font(.system(size: 12))
                .foregroundColor(ColorManager.black400)
            Spacer()
            if user.id == AuthViewModel.shared.currentUser?.id {
                Button {
                    self.showDeleteAlert.toggle()
                } label: {
                    Text("삭제")
                        .font(.system(size: 12))
                }
            }
            if AuthViewModel.shared.isManager {
                Button(role: .destructive) {
                    self.showMasterDeleteAlert.toggle()
                } label: {
                    Text("삭제")
                }
            }
        }
        .tint(ColorManager.black250)
    }
}

struct CommentView_Previews: PreviewProvider {
    static var previews: some View {
        CommentView(comment: MOCK_COMMENT, onDelete: {})
    }
}
