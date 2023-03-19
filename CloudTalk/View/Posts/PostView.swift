//
//  PostView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/01.
//

import SwiftUI

struct PostView: View {
    
    @ObservedObject var viewModel: PostViewModel
    @EnvironmentObject private var interstitialAd: InterstitialAd
    @State private var isLoading = false
    @State private var showPointAlert = false
    @State private var showWriteView = false
    
    var body: some View {
        ZStack {
            ColorManager.backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack(spacing: 0) {
                    titleLabel
                    Spacer()
                    filterButton
                        .padding(.trailing, 16)
                    writeButton
                }
                .frame(height: 52)
                .padding(.horizontal, 16)
                Rectangle()
                    .foregroundColor(.white)
                    .cornerRadius(36, corners: .topLeft)
                    .edgesIgnoringSafeArea(.bottom)
                    .padding(.top, 5)
            }
            Text("")
                .alert(isPresented: $showPointAlert) {
                    Alert(
                        title: Text("알림"),
                        message: Text("지금 게시물을 작성하면 50포인트를 받을 수 있습니다. 지금 받으러가시겠습니까?"),
                        primaryButton: .destructive(Text("받으러 가기"), action: {
                            self.showWriteView.toggle()
                        }),
                        secondaryButton: .cancel(Text("취소"))
                    )
                }
            CustomNavigationLink(
                destination: {
                    WriteView(onWrite: {
                        Task {
                            await viewModel.loadPosts()
                        }
                    })
                },
                isActive: $showWriteView,
                label: {
                    Text("")
                        .hidden()
                }
            )
            if viewModel.queriedPosts.count == 0 {
                VStack {
                    Image("cloud_sad")
                        .padding(.bottom, 18)
                    Text("표시할 게시글이 없습니다.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ColorManager.black500)
                }
            } else {
                VStack(spacing: 0) {
                    Spacer().frame(height: 57)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            LazyVStack(spacing: 0) {
                                ForEach(viewModel.queriedPosts) { post in
                                    PostCell(post: post, onDelete: {
                                        Task {
                                            await viewModel.loadPosts()
                                        }
                                    }).id(post.uid)
                                        .task {
                                            if viewModel.queriedPosts.count > 2 {
                                                await viewModel.fetchMorePosts(post: post)
                                            }
                                        }
                                }
                                Spacer().frame(height: 100)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.loadPosts()
                    }
                    .cornerRadius(36, corners: .topLeft)
                }
            }
        }
        .onAppear {
            interstitialAd.showAd()
            // TODO: Point Alert
            if !AuthViewModel.shared.isPointReceivedToday && !AuthViewModel.shared.isPointAlertComplete {
                self.showPointAlert.toggle()
                AuthViewModel.shared.isPointAlertComplete = true
            }
        }
        .overlay(
            isLoading ? LoadingView() : nil
        )
    }
    
    private var titleLabel: some View {
        Text("게시판")
            .foregroundColor(.white)
            .font(.bmjua(.regular, size: 24))
    }
    
    private var filterButton: some View {
        CustomNavigationLink {
            FilterView(
                gender: $viewModel.gender,
                region: $viewModel.region,
                ageRange: $viewModel.ageRange,
                onFilter: { gender, region, ageRange in
                    viewModel.storeFilterValue(gender: gender, region: region, ageRange: ageRange)
                })
        } label: {
            Image("filter")
        }
        
    }
    
    private var writeButton: some View {
        Button {
            self.showWriteView.toggle()
        } label: {
            Image("write")
        }
    }
}

//struct PostView_Previews: PreviewProvider {
//    static var previews: some View {
//        PostView()
//    }
//}
