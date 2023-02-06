//
//  ChatViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import Foundation
import Firebase

class ChatViewModel: ObservableObject {
    
    @Published var chats = [Chat]()
    
    init() {
        
    }
    
    func fetchChats() async {
        
    }
}
