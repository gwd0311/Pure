//
//  SplashView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import SwiftUI
import SDWebImageSwiftUI

struct SplashView: View {
    @State private var showGif = false
    var body: some View {
        ZStack {
            LinearGradient(colors: [ColorManager.skyBlueDark, ColorManager.purpleDark], startPoint: .topLeading, endPoint: .bottomTrailing)
                .ignoresSafeArea()
            
            if showGif {
                AnimatedImage(name: "cloudHeart.gif")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400)
            } else {
                ProgressView()
            }
            VStack(spacing: 0) {
                Spacer()
                Image("textlogo")
                    .padding(.bottom, 50)
            }
        }
        .onAppear {
            self.showGif = true
        }
        .onDisappear {
            self.showGif = false
        }
    }
}

struct SplashView_Previews: PreviewProvider {
    static var previews: some View {
        SplashView()
    }
}
