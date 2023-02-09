//
//  PostView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/01.
//

import SwiftUI

struct PostView: View {
    
    @ObservedObject var viewModel = PostViewModel()
    
    var body: some View {
        ZStack {
            ColorManager.backgroundColor.ignoresSafeArea()
            Rectangle()
                .foregroundColor(.white)
                .cornerRadius(36, corners: .topLeft)
                .edgesIgnoringSafeArea(.bottom)
                .padding(.top, 5)
            VStack(spacing: 0) {
                Spacer().frame(height: 5)
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.queriedPosts) { post in
                                PostCell(post: post).id(post.uid)
                                    .task {
                                        await viewModel.fetchMorePosts(post: post)
                                    }
                            }
                            Spacer().frame(height: 100)
                        }
                    }
                }
                .refreshable {
                    viewModel.loadPosts()
                }
                .cornerRadius(36, corners: .topLeft)
            }
        }
        .onWillAppear {
            viewModel.loadPosts()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                titleLabel
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                filterButton
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                writeButton
            }
        }
        .navigationTitle("")
        .navigationBarHidden(false)
    }
    
    private var titleLabel: some View {
        Text("구름게시판")
            .foregroundColor(.white)
            .font(.gmarketSans(.bold, size: 24))
    }
    
    private var filterButton: some View {
        
        CustomNavigationLink {
            FilterView(
                gender: $viewModel.gender,
                region: $viewModel.region,
                ageRange: $viewModel.ageRange,
                onFilter: { gender, region, ageRange in
                    viewModel.storeFilterValue(gender: gender, region: region, ageRange: ageRange)
                    viewModel.loadPosts()
                })
        } label: {
            Image("filter")
        }

    }
    
    private var writeButton: some View {
        CustomNavigationLink {
            WriteView(onRegister: {
                viewModel.loadPosts()
            })
        } label: {
            Image("write")
        }
    }
}

struct PostView_Previews: PreviewProvider {
    static var previews: some View {
        PostView()
    }
}
