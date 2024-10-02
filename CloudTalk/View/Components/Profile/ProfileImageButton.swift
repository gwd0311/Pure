//
//  ProfileImageButton.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/03/01.
//

import SwiftUI

enum ProfileImageButtonMode {
    case defaultMode
    case editMode
}

struct ProfileImageButton: View {
    
    let mode: ProfileImageButtonMode
    let user: AppUser
    @Binding var image: UIImage?
    @Binding var gender: Gender?
    @Binding var showImagePicker: Bool
    
    @State private var showSelectSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            if mode == .defaultMode {
                makeDefaultButton()
            } else if mode == .editMode {
                makeEditButton()
            }
        }
    }
    
    // MARK: - ActionSheet 거쳐서 열기
    @ViewBuilder private func makeEditButton() -> some View {
        Button {
            // TODO: 이미지 업로더 열기
            showSelectSheet.toggle()
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
                        profileImageUrl: "",
                        gender: self.gender ?? .man,
                        type: .roundRect,
                        width: 136,
                        height: 136,
                        radius: 40
                    )
                    .shadow(color: ColorManager.black500.opacity(0.08), radius: 8, x: 0, y: 0)
                }
            }
        }
        .actionSheet(isPresented: $showSelectSheet) {
            ActionSheet(title: Text("이미지 편집"), buttons: [
                .default(Text("이미지 바꾸기")) {
                    // 이미지 바꾸기 버튼을 누르면 이미지피커를 표시
                    showImagePicker.toggle()
                },
                .destructive(Text("이미지 삭제하기")) {
                    // 이미지 삭제하기 버튼을 누르면 삭제 알림을 표시
                    self.image = nil
                },
                .cancel()
            ])
        }
        .fullScreenCover(isPresented: $showImagePicker) {
            ImagePicker(image: $image)
        }
    }
    
    // MARK: - 이미지업로더 바로열기
    @ViewBuilder private func makeDefaultButton() -> some View {
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
                        gender: self.gender ?? .man,
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
        ProfileImageButton(mode: .editMode, user: MOCK_USER, image: .constant(nil), gender: .constant(.man), showImagePicker: .constant(false))
    }
}
