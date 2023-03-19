//
//  MainView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/25.
//

import SwiftUI
import Firebase

struct MainView: View {
    
    @ObservedObject var viewModel: MainViewModel
    @State private var isNavBarHidden = false
    @State private var scrollViewContentOffset = CGFloat(0)
    @State private var refreshed = 0
    @State private var isLoading = false
    
    var body: some View {
        ZStack {
            ColorManager.backgroundColor.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    titleLabel
                    Spacer()
                    filterButton
                }
                .frame(height: 52)
                .padding(.horizontal, 16)
                Rectangle()
                    .foregroundColor(ColorManager.black50)
                    .cornerRadius(36, corners: .topLeft)
                    .edgesIgnoringSafeArea(.bottom)
                    .padding(.top, 5)
            }
            if viewModel.queriedUsers.count == 0 {
                VStack {
                    Image("cloud_sad")
                        .padding(.bottom, 18)
                    Text("표시할 유저가 없습니다.")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(ColorManager.black500)
                }
            } else {
                VStack {
                    Spacer().frame(height: 57)
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 0) {
                            LazyVStack(spacing: 0) {
                                Spacer().frame(height: 12)
                                ForEach(viewModel.queriedUsers) { user in
                                    CustomNavigationLink {
                                        DetailView(user: user)
                                    } label: {
                                        UserCell(user: user)
                                            .id(user.id)
                                            .padding(.bottom, 8)
                                            .task {
                                                await viewModel.fetchMoreUsers(user: user)
                                            }
                                    }
                                    .id(user.id)
                                }
                                Spacer().frame(height: 100)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.loadUsers()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 16)
                    .cornerRadius(36, corners: .topLeft)
                    Spacer()
                }
            }
            
        }
        .overlay(
            isLoading ? LoadingView() : nil
        )
    }
    
    private var titleLabel: some View {
        Image("textlogo")
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
                    Task {
                        await viewModel.storeFilterValue(gender: gender, region: region, ageRange: ageRange)
                        await viewModel.loadUsers()
                    }
                })
        } label: {
            Image("filter")
        }
        
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView(viewModel: MainViewModel())
    }
}
