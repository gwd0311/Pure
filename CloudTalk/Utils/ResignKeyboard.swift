//
//  ResignKeyboard.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/09.
//

import SwiftUI

struct ResignKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onTapGesture {
                let keyWindow = UIApplication.shared.connectedScenes
                    .filter({$0.activationState == .foregroundActive})
                    .map({$0 as? UIWindowScene})
                    .compactMap({$0})
                    .first?.windows
                    .filter({$0.isKeyWindow}).first
                keyWindow?.endEditing(true)
            }
    }
}

extension View {
    func resignKeyboard() -> some View {
        modifier(ResignKeyboard())
    }
}
