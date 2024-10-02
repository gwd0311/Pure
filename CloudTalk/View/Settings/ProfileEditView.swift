//
//  ProfileEditView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/20.
//

import SwiftUI
import Kingfisher

enum ModalStatus {
    case none
    case nickName
    case gender
    case age
    case region
    case job
    case company
    case introduction
}

struct ProfileEditView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @Binding var isModalActive: Bool
    
    
    @State private var showImagePicker = false
    @State private var isLoading = false
    @State private var modalStatus: ModalStatus = .none
    @State private var showNickNameModal = false
    
    /// Input Value
    @State private var image: UIImage?
    @State private var nickName = AuthViewModel.shared.currentUser?.nickname
    @State private var gender = AuthViewModel.shared.currentUser?.gender
    @State private var region = AuthViewModel.shared.currentUser?.region
    @State private var job = AuthViewModel.shared.currentUser?.job
    @State private var company = AuthViewModel.shared.currentUser?.company
    @State private var age = AuthViewModel.shared.currentUser?.age
    @State private var introduction = AuthViewModel.shared.currentUser?.introduction
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        let user = viewModel.currentUser ?? MOCK_USER
        GeometryReader { geo in
            VStack {
                ScrollView {
                    VStack(spacing: 0) {
                        ProfileImageButton(
                            mode: .editMode,
                            user: user,
                            image: $image,
                            gender: $gender,
                            showImagePicker: $showImagePicker
                        )
                        .padding(.top, 32)
                        .padding(.bottom, 32)
                        makeInputButtons(user: user)
                        
                        Spacer().frame(height: 100)
                        
                    }
                    .frame(height: geo.size.height + 100)
                }
                makeCompleteButton(user: user)
                    .padding(.bottom, 44)
            }
            .overlay(
                isLoading ? LoadingView() : nil
            )
            .onAppear {
                if let url = URL(string: AuthViewModel.shared.currentUser?.profileImageUrl ?? "") {
                    KingfisherManager.shared.retrieveImage(with: url) { result in
                        switch result {
                        case .success(let value):
                            self.image = value.image
                        case .failure(let error):
                            // 오류 처리를 수행합니다.
                            print("Error: \(error)")
                        }
                    }
                }
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
        }
    }
    
    @ViewBuilder private func makeCompleteButton(user: AppUser) -> some View {
        Button {
            // TODO: viewModel 수정이벤트 추가
            isLoading = true
            viewModel.updateCurrentUser(
                image: image,
                nickname: nickName ?? user.nickname,
                gender: gender ?? user.gender,
                age: age ?? user.age,
                region: region ?? user.region,
                job: job ?? user.job,
                company: company ?? user.company,
                introduction: introduction ?? user.introduction,
                onUpdate: {
                    viewModel.fetchUser()
                    isLoading = false
                    dismiss()
                }
            )
        } label: {
            Text("완료")
        }
        .padding(.horizontal, 18)
        .buttonStyle(MainButtonStyle(color: ColorManager.blue))
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
                } else if modalStatus == .job {
                    WheelPickerModal(
                        modalStatus: $modalStatus,
                        type: .job,
                        onConfirm: { job in
                            self.job = Job(rawValue: job)
                        },
                        initialInt: self.job?.rawValue ?? 0
                    )
                } else if modalStatus == .company {
                    CompanyInputModal(
                        modalStatus: $modalStatus,
                        onConfirm: { company in
                            self.company = company
                        }
                    )
                }
            } else {
                EmptyView()
            }
        }
    }
    
    @ViewBuilder private func makeInputButtons(user: AppUser) -> some View {
        VStack(spacing: 0) {
            ProfileInputButton(title: "닉네임", content: self.nickName ?? "", onClick: {
                self.modalStatus = .nickName
            })
            ProfileInputButton(title: "성별", content: getGenderContent(), isOptional: true, onClick: {
                self.modalStatus = .gender
            })
            ProfileInputButton(title: "나이", content: getAgeContent(), isOptional: true, onClick: {
                self.modalStatus = .age
            })
            ProfileInputButton(title: "지역", content: self.region?.title ?? "", onClick: {
                self.modalStatus = .region
            })
            ProfileInputButton(title: "직업", content: self.job?.title ?? "", onClick: {
                self.modalStatus = .job
            })
            ProfileInputButton(title: "직장", content: getCompanyContent(), isOptional: true, onClick: {
                self.modalStatus = .company
            })
            ProfileInputButton(title: "내 소개", content: self.introduction ?? "", onClick: {
                self.modalStatus = .introduction
            })
        }
    }
    
    private func getGenderContent() -> String {
        guard let gender = self.gender else { return "" }
        if gender == .unknown {
            return "비공개"
        } else {
            return gender.title
        }
    }
    
    private func getAgeContent() -> String {
        guard let age = self.age else { return "" }
        if age == -1 {
            return "비공개"
        } else {
            return "\(age)세"
        }
    }
    
    private func getCompanyContent() -> String {
        guard let company = self.company else { return "" }
        if company == "" {
            return "비공개"
        } else {
            return company
        }
    }
}

struct ProfileEditView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileEditView(isModalActive: .constant(true))
            .environmentObject(AuthViewModel())
    }
}


