//
//  StoreCell.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/22.
//

import SwiftUI

struct StoreCell: View {
    let point: Int
    let price: Int
    
    var ratio: Int {
        let defaultPoint = Double(price) * (5.0 / 6.0)
        let bonusPoint = Double(point) - defaultPoint
        return Int(bonusPoint / defaultPoint * 100.0)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 0) {
                Image("setting1")
                    .padding(.trailing, 8)
                Text("\(point) 포인트")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ColorManager.black600)
                    .padding(.trailing, 6)
                if ratio > 0 {
                    Text("\(ratio)%")
                        .foregroundColor(ColorManager.blue)
                        .font(.system(size: 12, weight: .semibold))
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(ColorManager.purpleLight)
                        .cornerRadius(4)
                }
                Spacer()
                Text("\(price)원")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ColorManager.black400)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 25)
        }
        .background(.white)
        .cornerRadius(12)
    }
}

struct StoreCell_Previews: PreviewProvider {
    static var previews: some View {
        StoreCell(point: 3300, price: 3600)
    }
}
