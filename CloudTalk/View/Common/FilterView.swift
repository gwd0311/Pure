//
//  filterView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/26.
//

import SwiftUI

struct FilterView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    let onFilter: (Gender?, Region?, Int, Int) -> Void
    @ObservedObject var slider = CustomSlider(start: 18, end: 99)
    
    @State private var gender: Gender?
    @State private var region: Region?
    @State private var startAge: Int = 18
    @State private var endAge: Int = 99
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
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    authViewModel.showTabbar = true
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                        .foregroundColor(.black)
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    gender = nil
                    selectedIndex = -1
                    startAge = 18
                    endAge = 99
                    slider.initialize()
                } label: {
                    Text("초기화")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(ColorManager.black300)
                }
            }
        }
        .onAppear {
            DispatchQueue.main.async {
                authViewModel.showTabbar = false
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .navigationTitle("친구 검색")
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
            .onChange(of: selectedIndex, perform: { _ in
                region = Region(rawValue: selectedIndex) ?? nil
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
                Text("\(startAge)세 ~ \(endAge)세")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ColorManager.redLight)
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 36)
            SliderView(slider: slider)
                .onChange(of: slider.lowHandle.currentValue, perform: { newValue in
                    self.startAge = Int(newValue)
                })
                .onChange(of: slider.highHandle.currentValue, perform: { newValue in
                    self.endAge = Int(newValue)
                })
                .padding(.horizontal, 18)
                .padding(.bottom, 36)
        }
    }
    
    private var filterButton: some View {
        Button {
            // 뷰모델에 필터링 값들 넣기
            // 성별, 지역, 시작나이, 끝나이
            authViewModel.showTabbar = true
            onFilter(gender, region, Int(slider.lowHandle.currentValue), Int(slider.highHandle.currentValue))
            
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
