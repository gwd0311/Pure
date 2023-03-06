//
//  MainView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/25.
//

import SwiftUI
import Firebase

struct MainView: View {
    
    @ObservedObject var viewModel = MainViewModel()
    @State private var isNavBarHidden = false
    @State private var scrollViewContentOffset = CGFloat(0)
    @State private var refreshed = 0
    @State private var isLoading = true
    
    var body: some View {
        ZStack {
            ColorManager.backgroundColor.ignoresSafeArea()
            Rectangle()
                .foregroundColor(ColorManager.black50)
                .cornerRadius(36, corners: .topLeft)
                .edgesIgnoringSafeArea(.bottom)
                .padding(.top, 5)
            VStack {
                Spacer().frame(height: 5)
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
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    titleLabel
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    filterButton
                }
            }
            
        }
        .overlay(
            isLoading ? LoadingView() : nil
        )
        .task {
            self.isLoading = true
            await viewModel.loadUsers()
            self.isLoading = false
        }
    }
    
    private var titleLabel: some View {
        Text("구름톡")
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
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
