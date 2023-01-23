//
//  AgeSheetView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/23.
//

import SwiftUI

struct AgeSheetView: View {
    
    let viewModel: RegistrationViewModel
    @State private var selectedIndex = 18
    
    var body: some View {
        NavigationView {
            Form {
                Section("나이") {
                    Picker(selection: $selectedIndex, label: Text("")) {
                        ForEach(18...99, id: \.self) { index in
                            Text(String(index)).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                }
            }
            .navigationTitle("나이를 선택해주세요.")
            .navigationBarItems(trailing: Button("완료하기") {
                viewModel.setAge(selectedIndex: selectedIndex)
            })
            .onAppear {
                if let age = viewModel.age {
                    self.selectedIndex = Int(age) ?? 18
                }
            }
        }
    }
}

struct AgeSheetView_Previews: PreviewProvider {
    static var previews: some View {
        AgeSheetView(viewModel: RegistrationViewModel())
    }
}
