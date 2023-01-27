//
//  MainViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/27.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

class MainViewModel: ObservableObject {
    
    @Published var users = [User]()
    
    var query = COLLECTION_USERS
    
    init() {
        fetchUsers()
    }
    
    func fetchUsers() {
        query
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 7)
            .getDocuments { snapshot, err in
                if let err = err {
                    print("Error:: \(err)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }

                let users = documents.compactMap { try? $0.data(as: User.self) }
                    .filter { $0.id != Auth.auth().currentUser?.uid }
                
                DispatchQueue.main.async {
                    self.users = users
                }
        }
    }
    
    func fetchMoreUsers(user: User) async {
        guard user.id == users.last?.id else { return }
        guard let lastDoc = try? await COLLECTION_USERS.document(users.last?.id ?? "").getDocument() else { return DocumentSnapshot.initialize() }
        
        let snapshot = try? await query
            .order(by: KEY_TIMESTAMP, descending: true)
            .limit(to: 3)
            .start(afterDocument: lastDoc)
            .getDocuments()
        
        guard let documents = snapshot?.documents else { return }
        
        let users = documents.compactMap { try? $0.data(as: User.self) }
            .filter { $0.id != Auth.auth().currentUser?.uid }
        
        DispatchQueue.main.async {
            self.users += users
        }
    }
    
}
