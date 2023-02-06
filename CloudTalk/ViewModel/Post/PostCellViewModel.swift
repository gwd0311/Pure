//
//  PostCellViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/03.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class PostCellViewModel: ObservableObject {

    var post: Post
    @Published var comments = [Comment]()
    @Published var user: User?
    @Published var isHeartPressed = false
    @Published var heartCount = 0
    @Published var commentCount = 0
    
    init(post: Post) {
        self.post = post
        self.isHeartPressed = post.likeUids.contains(where: { $0 == AuthViewModel.shared.currentUser?.id })
        self.heartCount = post.likeCount
        self.commentCount = post.commentCount
        Task {
            await loadData()
        }
    }
    
    func loadData() async {
        await fetchPost()
        await fetchComments()
        await fetchUser()
    }
    
    func fetchComments() async {
        let snapShot = try? await COLLECTION_POSTS.document(post.uid).collection("comments").order(by: KEY_TIMESTAMP, descending: false).getDocuments()
        
        guard let comments = snapShot?.documents.compactMap({ try? $0.data(as: Comment.self) }) else { return }
        DispatchQueue.main.async {
            self.comments = comments
        }
    }
    
    private func fetchPost() async {
        let snapShot = try? await COLLECTION_POSTS.document(post.uid).getDocument()
        
        guard let post = try? snapShot?.data(as: Post.self) else { return }
        DispatchQueue.main.async {
            self.post = post
        }
    }
    
    private func fetchUser() async {
        let snapShot = try? await COLLECTION_USERS.document(post.uid).getDocument()
        
        guard let user = try? snapShot?.data(as: User.self) else { return }
        DispatchQueue.main.async {
            self.user = user
        }
    }
    
    func refresh() async {
        await fetchPost()
        await fetchComments()
    }
    
    func registerComment(text: String) async {
        guard let user = AuthViewModel.shared.currentUser else { return }
        let data: [String: Any] = [
            KEY_UID: user.id ?? "",
            KEY_COMMENT: text,
            KEY_NICKNAME: user.nickname,
            KEY_GENDER: user.gender.rawValue,
            KEY_PROFILE_IMAGE_URL: user.profileImageUrl,
            KEY_TIMESTAMP: Timestamp(date: Date())
        ]
        
        try? await COLLECTION_POSTS.document(post.uid).collection("comments").document().setData(data)
        try? await COLLECTION_POSTS.document(post.uid).updateData([KEY_COMMENT_COUNT: FieldValue.increment(Int64(1))])
        await self.fetchComments()
    }
    
    // MARK: - 하트 버튼 클릭
    func pressEmptyHeartButton(postId: String) async {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        let data: [AnyHashable: Any] = [
            KEY_LIKE_UIDS: FieldValue.arrayUnion([uid]),
            KEY_LIKE_COUNT: FieldValue.increment(Int64(1))
        ]
        try? await COLLECTION_POSTS.document(postId).updateData(data)
        DispatchQueue.main.async {
            self.isHeartPressed = true
            self.heartCount += 1
        }
    }
    
    func pressCompactedHeartButton(postId: String) async {
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        let data: [AnyHashable: Any] = [
            KEY_LIKE_UIDS: FieldValue.arrayRemove([uid]),
            KEY_LIKE_COUNT: FieldValue.increment(Int64(-1))
        ]
        try? await COLLECTION_POSTS.document(postId).updateData(data)
        DispatchQueue.main.async {
            self.isHeartPressed = false
            self.heartCount -= 1
        }
    }
    
}
