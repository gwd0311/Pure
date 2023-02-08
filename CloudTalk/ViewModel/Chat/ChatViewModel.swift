//
//  ChatViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class ChatViewModel: ObservableObject {
    
    @Published var chats = [Chat]()
    @Published var isLoading = false
    
    init() {
        self.fetchChats()
    }
    
    func fetchChats() {
        isLoading = true
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        
        COLLECTION_CHATS
            .whereField(KEY_UIDS, arrayContains: uid)
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 8)
            .getDocuments { snapShot, err in
            
            if let err = err {
                print(err.localizedDescription)
            }
            
            guard let chats = snapShot?.documents.compactMap({ try? $0.data(as: Chat.self) }) else { return }
            
            print(chats)
            
            self.chats = chats
            self.isLoading = false
        }
    }
    
    func fetchMore(chat: Chat) async {
        guard chat.id == chats.last?.id else { return }
        guard let lastDoc = try? await COLLECTION_POSTS.document(chats.last?.id ?? "").getDocument() else { return DocumentSnapshot.initialize() }
        guard let uid = AuthViewModel.shared.currentUser?.id else { return }
        
        let snapshot = try? await COLLECTION_CHATS
            .whereField(KEY_UIDS, arrayContains: uid)
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 7)
            .start(afterDocument: lastDoc)
            .getDocuments()
        
        guard let chats = snapshot?.documents.compactMap({ try? $0.data(as: Chat.self) }) else { return }
        
        DispatchQueue.main.async {
            self.chats += chats
        }
    }
}
