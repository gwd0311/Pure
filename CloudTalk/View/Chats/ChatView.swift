//
//  ChatView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/06.
//

import SwiftUI

struct ChatView: View {
    var body: some View {
        ZStack {
            ColorManager.backgroundColor.ignoresSafeArea()
            Rectangle()
                .foregroundColor(ColorManager.black50)
                .cornerRadius(36, corners: .topLeft)
                .edgesIgnoringSafeArea(.bottom)
                .padding(.top, 5)
            VStack(spacing: 0) {
                Spacer().frame(height: 5)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        LazyVStack(spacing: 0) {
                            Text("ddd")
                        }
                    }
                }
                .cornerRadius(36, corners: .topLeft)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                titleLabel
            }
        }
    }
    
    private var titleLabel: some View {
        Text("채팅방")
            .foregroundColor(.white)
            .font(.gmarketSans(.bold, size: 24))
    }
}

struct ChatView_Previews: PreviewProvider {
    static var previews: some View {
        ChatView()
    }
}
