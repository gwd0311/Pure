//
//  ProfileEditView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/20.
//

import SwiftUI

enum ModalStatus {
    case none
    case nickName
    case gender
    case age
    case region
    case introduction
}

struct ProfileEditView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var isModalActive: Bool
    
    @State private var image: UIImage?
    @State private var showImagePicker = false
    @State private var isLoading = false
    @State private var modalStatus: ModalStatus = .none
    @State private var showNickNameModal = false
    
    /// Input Value
    @State private var nickName = AuthViewModel.shared.currentUser?.nickname ?? ""
    @State private var gender = AuthViewModel.shared.currentUser?.gender
    @State private var region = AuthViewModel.shared.currentUser?.region
    @State private var age = AuthViewModel.shared.currentUser?.age
    @State private var introduction = AuthViewModel.shared.currentUser?.introduction
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        GeometryReader { geo in
            ScrollView {
                VStack(spacing: 0) {
                    let user = viewModel.currentUser ?? MOCK_USER
                    makeProfileImageButton(user: user)
                        .padding(.top, 32)
                        .padding(.bottom, 32)
                    makeInputButtons(user: user)
                    
                    Spacer()
                    Button {
                        // TODO: viewModel 수정이벤트 추가
                        viewModel.updateCurrentUser(
                            image: image,
                            nickname: nickName,
                            gender: gender ?? .man,
                            age: age ?? 20,
                            region: region ?? .seoul,
                            introduction: introduction ?? "",
                            onUpdate: {
                                viewModel.fetchUser()
                                dismiss()
                            }
                        )
                    } label: {
                        Text("완료")
                    }
                    .padding(.horizontal, 18)
                    .buttonStyle(MainButtonStyle(color: ColorManager.blue))
                }
                .frame(height: geo.size.height)
            }
            .onDisappear {
                AuthViewModel.shared.fetchUser()
            }
            .onChange(of: modalStatus, perform: { status in
                if status == .none {
                    isModalActive = false
                } else {
                    isModalActive = true
                }
            })
            .overlay(
                makeModal()
            )
            .customNavigationTitle("프로필 편집")
            .fullScreenCover(isPresented: $showImagePicker) {
                ImagePicker(image: $image)
            }
        }
    }
    
    // MARK: - 모달 만들기
    @ViewBuilder private func makeModal() -> some View {
        VStack {
            if isModalActive {
                if modalStatus == .nickName {
                    NicknameInputModal(
                        modalStatus: $modalStatus,
                        onConfirm: { text in
                            self.nickName = text
                        })
                } else if modalStatus == .gender {
                    WheelPickerModal(
                        modalStatus: $modalStatus,
                        type: .gender,
                        onConfirm: { genderValue in
                            self.gender = Gender(rawValue: genderValue)
                        },
                        initialInt: self.gender?.rawValue ?? 0
                    )
                } else if modalStatus == .region {
                    WheelPickerModal(
                        modalStatus: $modalStatus,
                        type: .region,
                        onConfirm: { regionValue in
                            self.region = Region(rawValue: regionValue)
                        },
                        initialInt: self.region?.rawValue ?? 0
                    )
                } else if modalStatus == .age {
                    WheelPickerModal(
                        modalStatus: $modalStatus,
                        type: .age,
                        onConfirm: { ageValue in
                            self.age = ageValue
                        },
                        initialInt: self.age ?? 20
                    )
                } else if modalStatus == .introduction {
                    IntroductionModal(
                        modalStatus: $modalStatus,
                        onConfirm: { introductionText in
                            self.introduction = introductionText
                        }
                    )
                }
            } else {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder private func makeInputButtons(user: User) -> some View {
        makeInputButton(title: "닉네임", content: self.nickName, action: {
            self.modalStatus = .nickName
        })
        
        makeInputButton(title: "성별", content: self.gender?.title ?? "입력해주세요", action: {
            self.modalStatus = .gender
        })
        makeInputButton(title: "나이", content: self.age == nil ? "입력해주세요" : "\(self.age ?? 20)세", action: {
            self.modalStatus = .age
        })
        makeInputButton(title: "지역", content: self.region?.title ?? "입력해주세요", action: {
            self.modalStatus = .region
        })
        makeInputButton(title: "내 소개", content: self.introduction ?? "입력해주세요", action: {
            self.modalStatus = .introduction
        })
    }
    
    @ViewBuilder private func makeInputButton(title: String, content: String, action: @escaping () -> Void) -> some View {
        Button {
            action()
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    Text(title)
                    Spacer()
                    Text(content.components(separatedBy: " ").joined().isEmpty ? "입력해주세요" : content)
                        .foregroundColor(content.components(separatedBy: " ").joined().isEmpty ? ColorManager.black200 : ColorManager.black600)
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
            }
            .background(ColorManager.black30)
            .cornerRadius(14)
            .padding(.horizontal, 18)
            .padding(.bottom, 10)
        }
        .tint(.black)
    }
    
    @ViewBuilder private func makeProfileImageButton(user: User) -> some View {
        Button {
            // TODO: 이미지 업로더 열기
            showImagePicker.toggle()
        } label: {
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
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(isModalActive: .constant(true))
            .environmentObject(AuthViewModel())
    }
}
