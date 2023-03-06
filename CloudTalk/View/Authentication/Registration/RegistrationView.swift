//
//  RegistrationView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/19.
//

import SwiftUI

struct RegistrationView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var showImagePicker = false

    @State private var isLoading = false
    @State private var image: UIImage?
    @State private var modalStatus: ModalStatus = .none
    @State private var isModalActive = false
    @State private var showAlert = false
    
    /// Input Values
    @State private var nickName: String?
    @State private var gender: Gender?
    @State private var region: Region?
    @State private var age: Int?
    @State private var introduction: String?
    
    var isInputComplete: Bool {
        self.nickName != nil && self.gender != nil && region != nil && self.age != nil && self.introduction != nil
    }
    
    var body: some View {
        CustomNavigationView {
            GeometryReader { geo in
                ScrollView {
                    VStack {
                        let user = viewModel.currentUser ?? MOCK_USER
                        ProfileImageButton(user: user, image: $image, showImagePicker: $showImagePicker)
                            .padding(.top, 32)
                            .padding(.bottom, 32)
                        makeInputButtons(user: user)
                        Spacer()
                        makeStartButton()
                    }
                    .frame(height: geo.size.height)
                    .customNavigationTitle("프로필")
                    .customNavBarItems(leading: makeBackButton())
                    .onChange(of: modalStatus, perform: { status in
                        if status == .none {
                            isModalActive = false
                        } else {
                            isModalActive = true
                        }
                    })
                }
            }
        }
        .alert("알림", isPresented: $showAlert, actions: {
            
        }, message: {
            Text("프로필 정보 등록 중 오류가 발생하였습니다\n네트워크 상태를 확인 후 다시시도해주세요")
        })
        .overlay(
            makeModal()
        )
        .overlay(isLoading ? LoadingView() : nil)
    }
    
    // MARK: - 뒤로가기 버튼
    @ViewBuilder private func makeBackButton() -> some View {
        Button {
            self.viewModel.signOut()
        } label: {
            Image(systemName: "chevron.backward")
        }
    }
    
    // MARK: - input 버튼들
    @ViewBuilder private func makeInputButtons(user: User) -> some View {
        VStack(spacing: 0) {
            ProfileInputButton(title: "닉네임", content: self.nickName ?? "", onClick: {
                self.modalStatus = .nickName
            })
            ProfileInputButton(title: "성별", content: self.gender?.title ?? "", onClick: {
                self.modalStatus = .gender
            })
            ProfileInputButton(title: "나이", content: self.age == nil ? "" : "\(self.age ?? 20)세", onClick: {
                self.modalStatus = .age
            })
            ProfileInputButton(title: "지역", content: self.region?.title ?? "", onClick: {
                self.modalStatus = .region
            })
            ProfileInputButton(title: "내 소개", content: self.introduction ?? "", onClick: {
                self.modalStatus = .introduction
            })
        }
    }
    
    @ViewBuilder private func makeStartButton() -> some View {
        Button {
            // TODO: viewModel register
            isLoading = true
            if let nickName = nickName,
               let gender = gender,
               let age = age,
               let region = region,
               let introduction = introduction {
                viewModel.setCurrentUser(
                    image: self.image,
                    nickname: nickName,
                    gender: gender,
                    age: age,
                    region: region,
                    introduction: introduction,
                    onSet: {
                        isLoading = false
                        viewModel.fetchUser()
                    }
                )
            } else {
                self.showAlert.toggle()
            }
            
        } label: {
            Text("시작하기")
        }
        .padding(.horizontal, 18)
        .buttonStyle(MainButtonStyle(color: isInputComplete ? ColorManager.blue : ColorManager.black150))
        .disabled(!isInputComplete)
    }
    
    // MARK: - 모달들
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
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
            .environmentObject(AuthViewModel())
    }
}
