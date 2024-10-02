//
//  CommentViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/14.
//

import SwiftUI

class CommentViewModel: ObservableObject {
    
    let comment: Comment
    @Published var user: AppUser?
    
    init(comment: Comment) {
        self.comment = comment
        Task {
            await fetchUser()
        }
    }
    
    private func fetchUser() async {
        let uid = comment.uid
        
        let snapshot = try? await COLLECTION_USERS.document(uid).getDocument()
            
        guard let user = try? snapshot?.data(as: AppUser.self) else { return }
        
        DispatchQueue.main.async {
            withAnimation {
                self.user = user
            }
        }
    }
    
    func masterDelete(completionHandler: @escaping () -> Void) {
        COLLECTION_POSTS.document(comment.pid).collection("comments").document(comment.id ?? "").updateData([
            KEY_COMMENT: "정책 위반으로 삭제된 댓글입니다."
        ]) { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            completionHandler()
        }
    }
    
    func delete(completionHandler: @escaping () -> Void) {
        COLLECTION_POSTS.document(comment.pid).collection("comments").document(comment.id ?? "").delete { err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            completionHandler()
        }
    }
}
