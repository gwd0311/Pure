//
//  ProfileImageButton.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/03/01.
//

import SwiftUI

struct ProfileImageButton: View {
    
    let user: User
    @Binding var image: UIImage?
    @Binding var showImagePicker: Bool
    
    var body: some View {
        Button {
            // TODO: 이미지 업로더 열기
            showImagePicker.toggle()
        } label: {
            VStack {
                if let image = image {
                    Color.clear
                        .aspectRatio(contentMode: .fill)
                        .overlay(
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                        )
                        .frame(width: 136, height: 136)
                        .clipped()
                        .contentShape(Rectangle())
                        .cornerRadius(40)
                        .shadow(color: ColorManager.black500.opacity(0.08), radius: 8, x: 0, y: 0)
                } else {
                    ProfileImageView(
                        profileImageUrl: user.profileImageUrl,
                        gender: user.gender,
                        type: .roundRect,
                        width: 136,
                        height: 136,
                        radius: 40
                    )
                    .shadow(color: ColorManager.black500.opacity(0.08), radius: 8, x: 0, y: 0)
                }
            }
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(image: $image)
        }
    }
}

struct ProfileImageButton_Previews: PreviewProvider {
    static var previews: some View {
        ProfileImageButton(user: MOCK_USER, image: .constant(nil), showImagePicker: .constant(false))
    }
}
