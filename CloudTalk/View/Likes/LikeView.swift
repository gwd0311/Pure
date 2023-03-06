//
//  LikeView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/14.
//

import SwiftUI

struct LikeView: View {
    
    @ObservedObject var viewModel = LikeViewModel()
    
    @State private var selectedTab = 0
    @State private var isLoading = true
    var body: some View {
        
        VStack(spacing: 0) {
            
            navigationSection
            
            // TODO: 탭뷰로 페이징 가능하게 하기
            TabView(selection: $selectedTab) {
                makeReceivedLikesSection().tag(0)
                makeMyLikesSection().tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            
            
        }
        .overlay(
            isLoading ? LoadingView() : nil
        )
        .task {
            isLoading = true
            try? await Task.sleep(nanoseconds: 0_200_000_000)
            isLoading = false
        }
    }
    
    @ViewBuilder private func makeMyLikesSection() -> some View {
        if viewModel.myLikes.count == 0 && !isLoading {
            VStack {
                Image("cloud_sad")
                    .padding(.bottom, 18)
                Text("아직 보낸 좋아요가 없어요.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ColorManager.black500)
            }
        } else {
            makeGridView(likeCards: viewModel.myLikes)
        }
    }
    
    @ViewBuilder private func makeReceivedLikesSection() -> some View {
        if viewModel.receivedLikes.count == 0 && !isLoading {
            VStack {
                Image("cloud_sad")
                    .padding(.bottom, 18)
                Text("아직 받은 좋아요가 없어요.")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ColorManager.black500)
            }
        } else {
            makeGridView(likeCards: viewModel.receivedLikes)
        }
    }
    
    @ViewBuilder private func makeGridView(likeCards: [LikeCard]) -> some View {
        ScrollView {
            Spacer().frame(height: 18)
            LazyVGrid(
                columns: [GridItem(.flexible()), GridItem(.flexible())],
                spacing: 18
            ) {
                ForEach(likeCards) { likeCard in
                    CustomNavigationLink {
                        DetailView(user: likeCard.user ?? MOCK_USER)
                    } label: {
                        LikeCardView(likeCard: likeCard)
                    }
                }
            }
        }
        .padding(.horizontal, 18)
    }
    
    private var navigationSection: some View {
        ZStack {
            Rectangle()
                .foregroundColor(ColorManager.black50)
                .frame(height: 1)
                .padding(.top, 51)
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 0) {
                Button {
                    // TODO: 받은 좋아요 클릭 시 받은 좋아요 모델 불러오기
                    withAnimation {
                        self.selectedTab = 0
                    }
                } label: {
                    makeTabMenu(
                        title: "받은 좋아요",
                        titleColor: (selectedTab == 0) ? ColorManager.black600 : ColorManager.black200,
                        isBottomLined: true
                    )
                }
                Button {
                    // TODO: 보낸 좋아요 클릭 시 받은 좋아요 모델 불러오기
                    withAnimation {
                        self.selectedTab = 1
                    }
                } label: {
                    makeTabMenu(
                        title: "보낸 좋아요",
                        titleColor: (selectedTab == 1) ? ColorManager.black600 : ColorManager.black200 ,
                        isBottomLined: false
                    )
                }
            }
        }
    }
    
    @ViewBuilder private func makeTabMenu(title: String, titleColor: Color, isBottomLined: Bool) -> some View {
        VStack(spacing: 0) {
            Text(title)
                .foregroundColor(titleColor)
                .font(.system(size: 18, weight: .bold))
                .padding(.bottom, 12)
                .padding(.top, 15)
            if isBottomLined {
                let width = UIScreen.main.bounds.width
                Rectangle()
                    .foregroundColor(ColorManager.backgroundColor)
                    .frame(width: 112, height: 3)
                    .offset(x: selectedTab == 0 ? 0 : width / 2 + 4)
            }
        }
        .frame(height: 52)
    }
}

struct LikeView_Previews: PreviewProvider {
    static var previews: some View {
        LikeView()
    }
}
