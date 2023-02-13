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
    
    private var listener: ListenerRegistration?
    
    var query = COLLECTION_CHATS
        .whereField(KEY_UIDS, arrayContains: AuthViewModel.shared.currentUser?.id ?? "")
        .order(by: KEY_TIMESTAMP, descending: true)
        .limit(to: 8)
    
    func startListen() {
        self.chats.removeAll()
        listener = query
            .addSnapshotListener { snapShot, err in
                
                if let err = err {
                    print(err.localizedDescription)
                }
                
                guard let chats = snapShot?.documents.compactMap({ try? $0.data(as: Chat.self) }) else { return }
                
                DispatchQueue.main.async {
                    self.chats = chats
                }
            }
    }
    
    func stopListen() {
        listener?.remove()
    }
    
    func fetchMore(chat: Chat) async {
        guard chat.id == chats.last?.id else { return }
        
        guard let lastDoc = try? await COLLECTION_CHATS.document(chats.last?.id ?? "").getDocument() else { return DocumentSnapshot.initialize() }
        
        let snapshot = try? await query
            .start(afterDocument: lastDoc)
            .getDocuments()
        
        guard let chats = snapshot?.documents.compactMap({ try? $0.data(as: Chat.self) }) else { return }
        
        DispatchQueue.main.async {
            self.chats += chats
        }
    }
}
