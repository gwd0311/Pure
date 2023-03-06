//
//  StoreView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/22.
//

import SwiftUI

struct StoreView: View {
    
    @StateObject private var viewModel = StoreViewModel()
    
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
                    viewModel.buyPoint(productID: "com.jerry.point1")
                } label: {
                    StoreCell(point: 1000, price: 1500)
                }
                .padding(.bottom, 8)
                Button {
                    viewModel.buyPoint(productID: "com.jerry.point2")
                } label: {
                    StoreCell(point: 3250, price: 4400)
                }
                .padding(.bottom, 8)
                Button {
                    viewModel.buyPoint(productID: "com.jerry.point3")
                } label: {
                    StoreCell(point: 6800, price: 8800)
                }
                .padding(.bottom, 8)
                Button {
                    viewModel.buyPoint(productID: "com.jerry.point4")
                } label: {
                    StoreCell(point: 12000, price: 15000)
                }
                .padding(.bottom, 8)
                Button {
                    viewModel.buyPoint(productID: "com.jerry.point5")
                } label: {
                    StoreCell(point: 25200, price: 29000)
                }
                .padding(.bottom, 8)
                
                Spacer()
            }
            .padding(.top, 24)
            .padding(.horizontal, 18)
        }
        .onAppear {
            viewModel.requestProducts()
        }
        .customNavigationTitle("스토어")
        .customNavBarItems(trailing: makePoint())
    }
    
    @ViewBuilder private func makePoint() -> some View {
        HStack(spacing: 4) {
            Image("setting1")
            Text("\(viewModel.currentPoint)")
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
