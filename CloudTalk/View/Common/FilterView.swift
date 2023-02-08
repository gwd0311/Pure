//
//  filterView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/26.
//

import SwiftUI

struct FilterView: View {
        
    @Binding var gender: Gender?
    @Binding var region: Region?
    @Binding var ageRange: ClosedRange<Float>
    let onFilter: (_ gender: Gender?, _ region: Region?, _ ageRange: ClosedRange<Float>) -> Void
    @State private var selectedIndex = -1
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            Divider()
                .padding(.bottom, 18)
            genderPart
                .padding(.bottom, 18)
            Divider()
                .padding(.bottom, 18)
            regionPart
            Divider()
                .padding(.bottom, 18)
            agePart
            Divider()
            Spacer()
            filterButton
        }
        .onWillAppear {
            DispatchQueue.main.async {
                if let region = region {
                    selectedIndex = region.rawValue
                } else {
                    selectedIndex = -1
                }
            }
        }
        .customNavigationTitle("친구 검색")
        .customNavBarItems(trailing: trailingButton)
        .navigationBarHidden(true)
        .navigationTitle("")
    }
    
    private var trailingButton: some View {
        Button {
            gender = nil
            region = nil
            selectedIndex = -1
            ageRange = 18...99
        } label: {
            Text("초기화")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(ColorManager.black300)
        }
    }
    
    private var genderPart: some View {
        VStack {
            HStack {
                Text("성별")
                    .font(.system(size: 16))
                    .foregroundColor(ColorManager.black600)
                Spacer()
                Text(gender?.title ?? "전체")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ColorManager.redLight)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 18)
            HStack(spacing: 8) {
                Button {
                    gender = nil
                } label: {
                    GenderSelectView(title: "전체", isSelected: gender == nil)
                }
                Button {
                    gender = .woman
                } label: {
                    GenderSelectView(title: "여자", isSelected: gender == .woman)
                }
                Button {
                    gender = .man
                } label: {
                    GenderSelectView(title: "남자", isSelected: gender == .man)
                }
            }
        }
    }
    
    private var regionPart: some View {
        VStack {
            HStack {
                Text("지역")
                    .font(.system(size: 16))
                    .foregroundColor(ColorManager.black600)
                Spacer()
                Text(Region(rawValue: selectedIndex)?.title ?? "전체")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ColorManager.redLight)
            }
            .padding(.horizontal, 18)
            Picker(selection: $selectedIndex, label: Text("Picker")) {
                Text("전체").tag(-1)
                ForEach(Region.allCases) { Text($0.title).tag($0.rawValue) }
            }
            .onChange(of: selectedIndex, perform: { newValue in
                region = newValue != -1 ? Region(rawValue: newValue) : nil
            })
            .pickerStyle(.wheel)
            .padding(.horizontal, 18)
            .frame(height: 150)
        }
    }
    private var agePart: some View {
        VStack {
            HStack {
                Text("나이")
                    .font(.system(size: 16))
                    .foregroundColor(ColorManager.black600)
                Spacer()
                Text("\(Int(ageRange.lowerBound))세 ~ \(Int(ageRange.upperBound))세")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ColorManager.redLight)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 36)
            RangedSliderView(value: $ageRange, bounds: 18...99)
                .padding(.horizontal, 18)
                .padding(.bottom, 36)
        }
    }
    
    private var filterButton: some View {
        Button {
            // 뷰모델에 필터링 값들 넣기
            // 성별, 지역, 시작나이, 끝나이
            onFilter(gender, region, ageRange)
            dismiss()
        } label: {
            Text("필터 적용하기")
        }
        .buttonStyle(MainButtonStyle(color: ColorManager.blue))
        .padding(.horizontal, 18)
        .padding(.bottom, 18)
    }
}

struct FilterView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}

struct GenderSelectView: View {
    
    let title: String
    let isSelected: Bool
    
    var body: some View {
        Text(title)
            .foregroundColor(isSelected ? ColorManager.black600 : ColorManager.black200)
            .font(.system(size: 16, weight: .bold))
            .padding(.horizontal, 40)
            .padding(.vertical, 14)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? ColorManager.black500 : ColorManager.black100, lineWidth: 1.5)
            )
    }
}
