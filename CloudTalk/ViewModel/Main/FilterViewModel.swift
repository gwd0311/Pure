//
//  MainFilterViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/27.
//

import Foundation

class FileterViewModel: ObservableObject {
    
    @Published var gender: Gender?
    @Published var region: Region?
    @Published var startAge: Int = 18
    @Published var endAge: Int = 99
    
    
}
