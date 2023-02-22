//
//  RegistrationView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/19.
//

import SwiftUI

struct RegistrationView: View {
    
    @ObservedObject var viewModel = RegistrationViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var showImagePicker = false
    @State private var currentProfileInfo: ProfileInfo = .nickname
    @State private var showSheet = false
    @State private var isLoading = false
    
    var body: some View {
        NavigationView {
            VStack {
                VStack {
                    HStack {Spacer()}
                    ScrollView {
                        titlePart
                        imageSelectorButton
                        Divider()
                        contentPart
                        Spacer().frame(height: 100)
                    }
                }
                .fullScreenCover(isPresented: $showImagePicker) {
                    ImagePicker(image: $viewModel.image)
                }
                .halfSheet(showSheet: $showSheet) {
                    switch currentProfileInfo {
                    case .nickname:
                        NicknameSheetView(viewModel: viewModel)
                    case .gender:
                        GenderSheetView(viewModel: viewModel)
                    case .age:
                        AgeSheetView(viewModel: viewModel)
                    case .region:
                        RegionSheetView(viewModel: viewModel)
                    case .introduction:
                        IntroductionSheetView(viewModel: viewModel)
                    }
                } onEnd: {
                    
                }
                .onReceive(viewModel.$showSheet) { showSheet in
                    self.showSheet = showSheet
                }
            }
            .navigationBarItems(trailing: saveButton)
        }
        .overlay(isLoading ? LoadingView() : nil)
    }
    
    private var titlePart: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("프로필 정보 입력")
                    .font(.cookieRun(.bold, size: 24))
                    .padding(.leading, 30)
                Spacer()
            }
            Spacer().frame(height: 10)
            Text("다른 회원들에게 보여줄 프로필 정보를 입력해주세요!")
                .font(.cookieRun(.regular, size: 14))
                .foregroundColor(Color(.systemGray))
                .padding(.leading, 30)
        }
    }
    
    private var imageSelectorButton: some View {
        Button {
            isLoading = true
            showImagePicker.toggle()
        } label: {
            if let image = viewModel.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .shadow(radius: 5)
                    .onAppear {
                        isLoading = false
                    }
            } else {
                Image(systemName: "cloud.fill")
                    .font(.system(size: 100))
                    .foregroundColor(.white)
                    .frame(width: 150, height: 150)
                    .padding()
                    .background(.blue)
                    .cornerRadius(15)
                    .shadow(radius: 5)
                    .overlay(
                        Image(systemName: "plus")
                            .font(.system(size: 30, weight: .black))
                            .offset(y: 10)
                    )
            }
        }
        .padding([.top, .bottom], 20)
    }
    
    private var contentPart: some View {
        VStack {
            Spacer().frame(height: 32)
            HStack {
                Text("기본 정보")
                    .font(.system(size: 18))
                    .fontWeight(.black)
                Spacer()
            }
            .padding(.bottom, 20)
            Button {
                currentProfileInfo = .nickname
                showSheet.toggle()
            } label: {
                ProfileInfoView(title: "닉네임", content: viewModel.nickname ?? "입력")
            }
            Button {
                currentProfileInfo = .gender
                showSheet.toggle()
            } label: {
                ProfileInfoView(title: "성별", content: viewModel.gender?.title ?? "입력")
            }
            Button {
                currentProfileInfo = .age
                showSheet.toggle()
            } label: {
                ProfileInfoView(title: "나이", content: viewModel.age != nil ? String(viewModel.age ?? 0) : "입력")
            }
            Button {
                currentProfileInfo = .region
                showSheet.toggle()
            } label: {
                ProfileInfoView(title: "지역", content: viewModel.region?.title ?? "입력")
            }
            Button {
                currentProfileInfo = .introduction
                showSheet.toggle()
            } label: {
                ProfileInfoView(title: "소개", content: viewModel.introduction ?? "입력")
            }
        }.padding(.horizontal, 20)
    }
    
    private var saveButton: some View {
        Button {
            viewModel.register {
                withAnimation {
                    authViewModel.fetchUser()
                }
            }
        } label: {
            Text("저장하고 시작하기")
                .font(.cookieRun(.regular))
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
