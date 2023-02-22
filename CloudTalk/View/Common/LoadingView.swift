//
//  LoadingView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        Rectangle()
            .foregroundColor(ColorManager.black200.opacity(0.2))
            .frame(width: 100, height: 100)
            .cornerRadius(30)
            .overlay(
                ProgressView()
                    .scaleEffect(3)
                    .tint(ColorManager.black400)
            )
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
