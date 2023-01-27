//
//  SplashView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.cyan
                .ignoresSafeArea()
            VStack {
                Image("cloud")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                    .shadow(radius: 3)
            }
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
