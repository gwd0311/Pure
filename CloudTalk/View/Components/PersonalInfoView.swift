//
//  PersonalInfoView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/03/15.
//

import SwiftUI

struct PersonalInfoView: View {
    
    let gender: Gender
    let age: Int
    let region: Region
    let fontSize: CGFloat
    let spacing: CGFloat
    
    init(gender: Gender, age: Int, region: Region, fontSize: CGFloat = 13, spacing: CGFloat = 4) {
        self.gender = gender
        self.age = age
        self.region = region
        self.fontSize = fontSize
        self.spacing = spacing
    }
    
    var body: some View {
        HStack(spacing: 4) {
            Group {
                Text(gender.title)
                    .foregroundColor(gender.color)
                Text("·")
                Text(getAgeContent())
                Text("·")
                Text(region.title)
            }
            .foregroundColor(ColorManager.black400)
            .font(.system(size: self.fontSize))
        }
    }
    
    private func getAgeContent() -> String {
        if self.age == -1 {
            return "비공개"
        } else {
            return "\(age)살"
        }
    }
}

struct PersonalInfoView_Previews: PreviewProvider {
    static var previews: some View {
        PersonalInfoView(
            gender: .unknown,
            age: -1,
            region: .busan
        )
    }
}
