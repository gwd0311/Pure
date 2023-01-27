//
//  RegionSheetView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/23.
//

import SwiftUI

struct RegionSheetView: View {
    
    let viewModel: RegistrationViewModel
    
    @State private var selectedIndex = 0
    
    var body: some View {
        NavigationView {
            Form {
                Section("지역") {
                    Picker(selection: $selectedIndex, label: Text("")) {
                        ForEach(0..<Region.allCases.count, id: \.self) { index in
                            Text(Region.allCases[index].title).tag(index)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: 150)
                }
            }
            .navigationTitle("지역을 선택해주세요.")
            .navigationBarItems(trailing: Button("완료하기") {
                viewModel.setRegion(selectedIndex: selectedIndex)
            })
            .onAppear {
                guard let region = viewModel.region else { return }
                guard let index = Region.allCases.firstIndex(of: region) else { return }
                self.selectedIndex = index
            }
        }
    }
}

struct RegionSheetView_Previews: PreviewProvider {
    static var previews: some View {
        RegionSheetView(viewModel: RegistrationViewModel())
    }
}
