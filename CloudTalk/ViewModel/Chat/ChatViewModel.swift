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
        self.listener = query
            .addSnapshotListener { snapShot, err in
                
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                
                snapShot?.documentChanges.forEach({ diff in
                    if (diff.type == .added) {
                        guard let chat = try? diff.document.data(as: Chat.self) else { return }
                        DispatchQueue.main.async {
                            self.chats.append(contentsOf: chat)
                            print(self.chats)
                        }
                    }
                    if (diff.type == .modified) {
                        guard let chat = try? diff.document.data(as: Chat.self) else { return }
                        guard let index = self.chats.firstIndex(where: { $0.id == chat.id }) else { return }
                        DispatchQueue.main.async {
                            self.chats[index] = chat
                        }
                    }
                    if (diff.type == .removed) {
                        guard let chat = try? diff.document.data(as: Chat.self) else { return }
                        guard let index = self.chats.firstIndex(where: { $0.id == chat.id }) else { return }
                        DispatchQueue.main.async {
                            self.chats.remove(at: index)
                        }
                    }
                })
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
    
    func delete(chat: Chat) {
        guard let cid = chat.id else { return }
        if chat.uids.count == 1 {
            
            // 대화내용 모두 삭제
            COLLECTION_CHATS.document(cid).collection("messages").getDocuments { snapshot, err in
                
                if let err = err {
                    print(err.localizedDescription)
                    return
                }
                
                snapshot?.documents.forEach({ snapshot in
                    snapshot.reference.delete()
                })
                    
                // 문서 삭제
                COLLECTION_CHATS.document(cid).delete { err in
                    
                    if let err = err {
                        print(err.localizedDescription)
                        return
                    }
                    
                    DispatchQueue.main.async {
                        self.chats.removeAll(where: { $0.id == cid })
                    }
                    
                }
            }
            

        } else {
            // 남은 유저가 2명이면 uids에서 나간사람을 제거해라
            var uids = chat.uids
            uids = uids.filter({ $0 != AuthViewModel.shared.currentUser?.id })
            
            COLLECTION_CHATS.document(cid).updateData([KEY_UIDS: uids]) { err in
                
                if let err = err {
                    print(err.localizedDescription)
                }
                
                DispatchQueue.main.async {
                    self.chats.removeAll(where: { $0.id == cid })
                }
            }
        }
    }
    
}
