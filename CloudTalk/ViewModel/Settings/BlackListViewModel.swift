//
//  BlackListViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/21.
//

import Foundation

class BlackListViewModel: ObservableObject {
    
    @Published var blackUsers = [User]()
    
    init() {
        Task {
            await fetchUsers()
        }
    }
    
    func fetchUsers() async {
        
        self.blackUsers.removeAll()
        
        let uids = await AuthViewModel.shared.blackUids
        
        for uid in uids {
            let snapshot = try? await COLLECTION_USERS.document(uid).getDocument()
            guard let user = try? snapshot?.data(as: User.self) else { return }
            DispatchQueue.main.async {
                self.blackUsers.append(user)
            }
        }
        
    }
}
