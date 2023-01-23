//
//  GenderSheetView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/23.
//

import SwiftUI

struct GenderSheetView: View {
    
    let viewModel: RegistrationViewModel
    @State private var selectedIndex = 1
    
    var body: some View {
        NavigationView {
            Form {
                Section("성별") {
                    Picker(selection: $selectedIndex, label: Text("성별")) {
                        Text("남성").tag(1)
                        Text("여성").tag(2)
                    }
                }
                Button("완료하기") {
                    viewModel.setGender(selectedIndex: selectedIndex)
                }
            }
            .navigationTitle("성별을 골라주세요.")
            .onAppear {
                if let gender = viewModel.gender {
                    switch gender {
                    case "남성":
                        selectedIndex = 1
                    case "여성":
                        selectedIndex = 2
                    default:
                        break
                    }
                }
            }
        }
    }
}

struct GenderSheetView_Previews: PreviewProvider {
    static var previews: some View {
        GenderSheetView(viewModel: RegistrationViewModel())
    }
}
