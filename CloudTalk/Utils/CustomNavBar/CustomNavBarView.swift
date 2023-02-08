//
//  CustomNavBarView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/01.
//

import SwiftUI

struct CustomNavBarView<Content: View>: View {
    
    @Environment(\.dismiss) var dismiss
    let showBackButton: Bool
    let title: String
    let leading: Content?
    let trailing: Content?
    
    var body: some View {
        VStack {
            ZStack {
                HStack(spacing: 0) {
                    if showBackButton {
                        backButton
                            .padding(.leading, 18)
                    } else {
                        leading
                            .padding(.leading, 18)
                    }
                    Spacer()
                    if let trailing = trailing {
                        trailing
                            .padding(.trailing, 14)
                    } else {
                        Text("")
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 14)
                            .hidden()
                    }
                }
                .frame(height: 52)
                .tint(.clear)
                .foregroundColor(.black)
                .font(.headline)
                .background(
                    Color.white.opacity(0).ignoresSafeArea(edges: .top)
                )
                HStack(spacing: 0) {
                    Spacer()
                    titleSection
                    Spacer()
                }
            }
            Rectangle()
                .foregroundColor(ColorManager.black50)
                .frame(height: 1)
        }
        .background(.clear.opacity(0))
    }
}

extension CustomNavBarView {
    
    private var backButton: some View {
        Button {
            dismiss()
        } label: {
            VStack {
                Image("back")
            }
            .frame(width: 24, height: 24)
        }
    }
    
    private var titleSection: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.system(size: 18, weight: .black))
        }
    }
}

struct CustomNavBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            CustomNavBarView(showBackButton: true, title: "최대여섯글자", leading: Text("dd"), trailing: nil)
            Spacer()
        }
    }
}
