//
//  BlackListView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/21.
//

import SwiftUI

struct BlackListView: View {
    
    @ObservedObject var viewModel = BlackListViewModel()
    
    var body: some View {
        ZStack {
            ColorManager.black50.ignoresSafeArea()
            if AuthViewModel.shared.blackUids.count == 0 {
                VStack {
                    Image("cloud_x")
                        .padding(.bottom, 18)
                    Text("차단한 회원이 없습니다.")
                        .foregroundColor(ColorManager.black500)
                        .font(.system(size: 16, weight: .semibold))
                }
            } else {
                ScrollView(showsIndicators: false) {
                    LazyVStack(spacing: 0) {
                        Spacer().frame(height: 16)
                        ForEach(viewModel.blackUsers) { user in
                            BlackCell(blackUsers: $viewModel.blackUsers, user: user)
                                .padding(.bottom, 6)
                        }
                    }
                    .padding(.horizontal, 18)
                }
            }
        }
        .customNavigationTitle("차단 목록")
    }
}

struct BlackListView_Previews: PreviewProvider {
    static var previews: some View {
        BlackListView()
    }
}
