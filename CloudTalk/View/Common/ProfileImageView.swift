//
//  ProfileImageView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/08.
//

import SwiftUI
import Kingfisher

enum ProfileImageType {
    case circle
    case roundRect
}

struct ProfileImageView: View {
    
    let user: User
    let type: ProfileImageType
    var width: CGFloat? = 46
    var height: CGFloat? = 46
    var radius: CGFloat? = 12
    
    init(user: User, type: ProfileImageType, width: CGFloat? = 46, height: CGFloat? = 46, radius: CGFloat? = 12) {
        self.user = user
        self.type = type
        self.width = width
        self.height = height
        self.radius = radius
    }
    
    var body: some View {
        if let width = width,
           let height = height,
           let radius = radius {
            VStack {
                if !user.profileImageUrl.isEmpty {
                    if type == .circle {
                        Color.clear
                            .aspectRatio(contentMode: .fill)
                            .overlay(
                                KFImage(URL(string: user.profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(width: width, height: height)
                            .modifier(CircleModifier())
                    } else {
                        Color.clear
                            .aspectRatio(contentMode: .fill)
                            .overlay(
                                KFImage(URL(string: user.profileImageUrl))
                                    .resizable()
                                    .scaledToFill()
                            )
                            .frame(width: width, height: height)
                            .modifier(RectModifier(radius: radius ))
                    }
                    
                } else if user.gender == .man {
                    if type == .circle {
                        Image("man")
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .modifier(CircleModifier())
                    } else {
                        Image("man")
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .modifier(RectModifier(radius: radius))
                    }
                } else {
                    if type == .circle {
                        Image("woman")
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .modifier(CircleModifier())
                    } else {
                        Image("woman")
                            .resizable()
                            .scaledToFill()
                            .frame(width: width, height: height)
                            .modifier(RectModifier(radius: radius))
                    }
                }
            }
        }
    }
}

struct ProfileImageView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageView(user: MOCK_USER, type: .roundRect)
    }
}

struct CircleModifier: ViewModifier {
    
    func body(content: Content) -> some View {
        content
            .clipShape(Circle())
            .contentShape(Circle())
            .allowsHitTesting(false)
    }
    
}

struct RectModifier: ViewModifier {
    
    let radius: CGFloat
    
    init(radius: CGFloat = 12) {
        self.radius = radius
    }
    
    func body(content: Content) -> some View {
        content
            .clipShape(Rectangle())
            .contentShape(Rectangle())
            .cornerRadius(radius)
            .allowsHitTesting(false)
    }
    
}
