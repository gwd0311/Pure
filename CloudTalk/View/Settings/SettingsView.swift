//
//  SettingsView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/27.
//

import SwiftUI
import Firebase

struct SettingsView: View {
    
    @EnvironmentObject var viewModel: AuthViewModel
    @State private var isPushOn = true
    @State private var isModalActive = false
    
    var body: some View {
        ZStack {
            ColorManager.skyBlue.ignoresSafeArea()
            VStack {
                Rectangle()
                    .foregroundColor(.white)
                    .cornerRadius(36, corners: .topLeft)
                    .padding(.top, 500)
                    .edgesIgnoringSafeArea(.bottom)
            }
            ScrollView(showsIndicators: false) {
                ZStack {
                    VStack {
                        Rectangle()
                            .foregroundColor(.white)
                            .cornerRadius(36, corners: .topLeft)
                            .padding(.top, 136)
                            .edgesIgnoringSafeArea(.bottom)
                    }
                    let user = viewModel.currentUser ?? MOCK_USER
                    VStack(spacing: 0) {
                        Spacer().frame(height: 44)
                        makeProfileImageButton(user: user)
                            .padding(.bottom, 17)
                        
                        Text(user.nickname)
                            .foregroundColor(ColorManager.black600)
                            .font(.system(size: 20, weight: .semibold))
                            .padding(.bottom, 20)
                        
                        VStack {
                            makePointSection()
                                .padding(.bottom, 34)
                            makeDefaultSection()
                                .padding(.bottom, 34)
                            makeAppInfoSection()
                                .padding(.bottom, 34)
                            makeSignSection()
                            Spacer().frame(height: 130)
                        }
                    }
                }
            }
            .padding(.top, 0.3)
        }
    }
    
    // MARK: - 로그아웃, 회원탈퇴 섹션
    @ViewBuilder private func makeSignSection() -> some View {
        VStack(spacing: 0) {
            VStack(spacing: 0) {
                logOutButton
                Divider()
                withdrawalButton
            }
            .background(ColorManager.black30)
            .cornerRadius(12)
        }
        .padding(.horizontal, 18)
    }
    
    private var withdrawalButton: some View {
        Button {
            // TODO: 회원탈퇴 기능 구현
            
        } label: {
            HStack(spacing: 0) {
                Spacer().frame(width: 4)
                Text("탈퇴하기")
                    .sectionContentTextStyle()
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }
    
    private var logOutButton: some View {
        Button {
            viewModel.signOut()
        } label: {
            HStack(spacing: 0) {
                Spacer().frame(width: 4)
                Text("로그아웃")
                    .sectionContentTextStyle()
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - 앱 정보 섹션
    @ViewBuilder private func makeAppInfoSection() -> some View {
        VStack(spacing: 0) {
            makeSectionTitle(title: "앱 정보")
            VStack(spacing: 0) {
                makeSectionContent(imageName: "setting5", title: "서비스 이용약관", content: {}, destination: {})
                Divider()
                    .foregroundColor(ColorManager.black100)
                makeSectionContent(imageName: "setting6", title: "개인정보 처리방침", content: {}, destination: {})
                Divider()
                    .foregroundColor(ColorManager.black100)
                makeAppVersionContent(imageName: "setting7", title: "앱버전", content: {
                    Text("1.0.0")
                        .font(.system(size: 16, weight: .light))
                        .foregroundColor(ColorManager.black400)
                })
            }
            .background(ColorManager.black30)
            .cornerRadius(12)
        }
        .padding(.horizontal, 18)
    }
    
    // MARK: - 기본 설정 섹션
    @ViewBuilder private func makeDefaultSection() -> some View {
        VStack(spacing: 0) {
            makeSectionTitle(title: "기본 설정")
            VStack(spacing: 0) {
                makePushSectionContent(imageName: "setting2", title: "푸쉬알림", content: {
                    Toggle(isOn: self.$isPushOn) {
                        EmptyView()
                    }
                    .tint(ColorManager.blue)
                })
                Divider()
                    .foregroundColor(ColorManager.black100)
                makeSectionContent(imageName: "setting3", title: "문의하기", content: {}, destination: {})
                Divider()
                    .foregroundColor(ColorManager.black100)
                makeSectionContent(imageName: "setting4", title: "차단목록", content: {}, destination: {
                    BlackListView()
                })
            }
            .background(ColorManager.black30)
            .cornerRadius(12)
        }
        .padding(.horizontal, 18)
    }
    
    // MARK: - 섹션 Title
    @ViewBuilder private func makeSectionTitle(title: String) -> some View {
        HStack {
            Text(title)
                .sectionTitleTextStyle()
            Spacer()
        }
        .padding(.bottom, 10)
    }
    
    // MARK: - 섹션 Content
    private func makeSectionContent<Content: View, Destination: View>(imageName: String, title: String, @ViewBuilder content: () -> Content, @ViewBuilder destination: () -> Destination) -> some View {
        CustomNavigationLink {
            destination()
        } label: {
            HStack(spacing: 0) {
                Image(imageName)
                    .padding(.trailing, 10)
                Text(title)
                    .sectionContentTextStyle()
                Spacer()
                content()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 12)
        }
    }
    
    // MARK: - 푸쉬알림 섹션 Content
    private func makePushSectionContent<Content: View>(imageName: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 0) {
            Image(imageName)
                .padding(.trailing, 10)
            Text(title)
                .sectionContentTextStyle()
            Spacer()
            content()
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 10)
    }
    
    // MARK: - 앱 버전 Content
    private func makeAppVersionContent<Content: View>(imageName: String, title: String, @ViewBuilder content: () -> Content) -> some View {
        HStack(spacing: 0) {
            Image(imageName)
                .padding(.trailing, 10)
            Text(title)
                .sectionContentTextStyle()
            Spacer()
            content()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
    }
    
    // MARK: - 포인트 섹션
    @ViewBuilder private func makePointSection() -> some View {
        VStack(alignment: .leading, spacing: 0) {
            makeSectionTitle(title: "내 포인트")
            VStack {
                makeSectionContent(imageName: "setting1", title: "스토어", content: {
                    Text("\(viewModel.currentUser?.point ?? 0) P")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ColorManager.blue)
                }, destination: {
                    StoreView()
                })
            }
            .background(ColorManager.black30)
            .cornerRadius(12)
        }
        .padding(.horizontal, 18)
    }
    
    // MARK: - 프로필 편집 버튼 (편집 페이지로 이동)
    @ViewBuilder private func makeProfileImageButton(user: User) -> some View {
        CustomNavigationLink(destination: {
            // TODO: 프로필 편집 페이지로 이동
            ProfileEditView(isModalActive: $isModalActive)
        }, label: {
                ProfileImageView(
                    profileImageUrl: user.profileImageUrl,
                    gender: user.gender,
                    type: .roundRect,
                    width: 136,
                    height: 136,
                    radius: 40
                )
                .shadow(color: ColorManager.black500.opacity(0.08), radius: 8, x: 0, y: 0)
                .overlay(
                    Circle()
                        .foregroundColor(.white)
                        .frame(width: 40, height: 40)
                        .overlay(
                            Circle()
                                .stroke(lineWidth: 1.5)
                                .foregroundColor(ColorManager.black100)
                        )
                        .overlay(
                            Image("edit")
                        )
                        .offset(x: 7, y: 7)
                    , alignment: .bottomTrailing
                )
        }, isModalActive: $isModalActive)
    }
}

struct SectionTitleText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 14, weight: .semibold))
            .foregroundColor(ColorManager.black300)
    }
}

struct SectionContentText: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 16, weight: .light))
            .foregroundColor(ColorManager.black600)
    }
}

extension View {
    func sectionTitleTextStyle() -> some View {
        modifier(SectionTitleText())
    }
    
    func sectionContentTextStyle() -> some View {
        modifier(SectionContentText())
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(AuthViewModel())
    }
}
