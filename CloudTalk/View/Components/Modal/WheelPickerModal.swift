//
//  WheelPickerModal.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/21.
//

import SwiftUI

enum ItemType {
    case gender
    case age
    case region
    case job
    
    var title: String {
        switch self {
        case .gender:
            return "성별 입력"
        case .age:
            return "나이 입력"
        case .region:
            return "지역 입력"
        case .job:
            return "직업 입력"
        }
    }
}

struct WheelPickerModal: View {
    
    @Binding var modalStatus: ModalStatus
    let type: ItemType
    let onConfirm: (Int) -> Void
    
    @State private var selectedInt: Int
    
    init(modalStatus: Binding<ModalStatus>, type: ItemType, onConfirm: @escaping (Int) -> Void, initialInt: Int) {
        _modalStatus = modalStatus
        self.type = type
        self.onConfirm = onConfirm
        _selectedInt = State(initialValue: initialInt)
    }
    
    var body: some View {
        ZStack {
            Color.black
                .opacity(0.5)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    self.modalStatus = .none
                }
            VStack {
                Text(type.title)
                    .foregroundColor(ColorManager.black600)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.bottom, 2)
                Divider()
                    .foregroundColor(ColorManager.black50)
                VStack {
                    makePicker()
                    Button {
                        onConfirm(selectedInt)
                        self.modalStatus = .none
                    } label: {
                        Text("확인")
                    }
                    .frame(height: 48)
                    .buttonStyle(MainButtonStyle(color: ColorManager.blue))
                }
                .padding(.horizontal, 16)
            }
            .padding(.vertical, 18)
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(24)
            .padding(.horizontal, 40)
        }
    }
    
    @ViewBuilder private func makePicker() -> some View {
        if type == .gender {
            Picker(selection: $selectedInt, label: Text("Gender")) {
                ForEach(Gender.allCases, id:\.self) { gender in
                    Text(gender.title).tag(gender.rawValue)
                }
            }
            .pickerStyle(.wheel)
        } else if type == .age {
            Picker(selection: $selectedInt, label: Text("Age")) {
                Text("비공개").tag(-1)
                ForEach((18...99), id:\.self) { age in
                    Text(age.description).tag(age)
                }
            }
            .pickerStyle(.wheel)
        } else if type == .region {
            Picker(selection: $selectedInt, label: Text("Region")) {
                ForEach(Region.allCases, id:\.self) { region in
                    Text(region.title).tag(region.rawValue)
                }
            }
            .pickerStyle(.wheel)
        } else if type == .job {
            Picker(selection: $selectedInt, label: Text("Job")) {
                ForEach(Job.allCases, id:\.self) { job in
                    Text(job.title).tag(job.rawValue)
                }
            }
            .pickerStyle(.wheel)
        }
    }
}

struct WheelPickerModal_Previews: PreviewProvider {
    static var previews: some View {
        WheelPickerModal(modalStatus: .constant(.gender), type: .gender, onConfirm: { _ in }, initialInt: 0)
    }
}
