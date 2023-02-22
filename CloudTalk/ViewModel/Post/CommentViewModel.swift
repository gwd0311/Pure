//
//  CommentViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/14.
//

import Foundation

class CommentViewModel: ObservableObject {
    
    let comment: Comment
    @Published var user: User?
    
    init(comment: Comment) {
        self.comment = comment
        fetchUser()
    }
    
    private func fetchUser() {
        let uid = comment.uid
        
        COLLECTION_USERS.document(uid).getDocument { snapshot, err in
            if let err = err {
                print(err.localizedDescription)
                return
            }
            
            guard let user = try? snapshot?.data(as: User.self) else { return }
            
            self.user = user
        }
    }
}
