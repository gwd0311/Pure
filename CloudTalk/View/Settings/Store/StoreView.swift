//
//  StoreView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/22.
//

import SwiftUI

struct StoreView: View {
    var body: some View {
        ZStack {
            ColorManager.black50.ignoresSafeArea()
            VStack(spacing: 0) {
                HStack {
                    Text("포인트 구매")
                        .font(.system(size: 18, weight: .black))
                    Spacer()
                }
                .padding(.bottom, 20)
                Button {
                    
                } label: {
                    StoreCell(point: 1000, price: 1200)
                }
                .padding(.bottom, 8)
                Button {
                    
                } label: {
                    StoreCell(point: 3300, price: 3600)
                }
                .padding(.bottom, 8)
                Button {
                    
                } label: {
                    StoreCell(point: 5750, price: 6000)
                }
                .padding(.bottom, 8)
                Button {
                    
                } label: {
                    StoreCell(point: 12000, price: 12000)
                }
                .padding(.bottom, 8)
                Button {
                    
                } label: {
                    StoreCell(point: 37500, price: 36000)
                }
                .padding(.bottom, 8)
                
                Spacer()
            }
            .padding(.top, 24)
            .padding(.horizontal, 18)
        }
        .customNavigationTitle("스토어")
        .customNavBarItems(trailing: makePoint())
    }
    
    @ViewBuilder private func makePoint() -> some View {
        HStack(spacing: 4) {
            Image("setting1")
            Text("\(AuthViewModel.shared.currentUser?.point ?? 0)")
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(ColorManager.black600)
        }
    }
}

struct StoreView_Previews: PreviewProvider {
    static var previews: some View {
        StoreView()
    }
}
