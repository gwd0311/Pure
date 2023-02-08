//
//  LoadingView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        Color.black.opacity(0.4).ignoresSafeArea()
            .overlay(
                ProgressView().tint(.white)
            )
    }
}

struct LoadingView_Previews: PreviewProvider {
    static var previews: some View {
        LoadingView()
    }
}
