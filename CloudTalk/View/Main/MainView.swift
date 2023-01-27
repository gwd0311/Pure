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
    
    var body: some View {
        NavigationView {
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
                        LazyVStack(spacing: 0) {
                            ForEach(viewModel.users) { user in
                                UserCell(user: user)
                                    .padding(.bottom, 12)
                                    .task {
                                        await viewModel.fetchMoreUsers(user: user)
                                    }
                            }
                            Spacer().frame(height: 100)
                        }
                    }
                    .refreshable {
                        viewModel.fetchUsers()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 18)
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
                .navigationBarHidden(isNavBarHidden)
            }
        }
    }
    
    
    
    private var titleLabel: some View {
        Text("구름톡")
            .foregroundColor(.white)
            .font(.gmarketSans(.bold, size: 24))
    }
    
    private var filterButton: some View {
        NavigationLink {
            FilterView(onFilter: { gender, region, startAge, endAge in
                print(gender, region, startAge, endAge)
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
