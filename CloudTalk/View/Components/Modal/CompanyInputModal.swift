//
//  CompanyInputModal.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/03/09.
//

import SwiftUI

import SwiftUI
import Introspect

struct CompanyInputModal: View {
    
    @Binding var modalStatus: ModalStatus
    let onConfirm: (String) -> Void
    @State private var text: String = ""
    
    var isCorrect: Bool {
        let pattern = #"[A-Za-z가-힣\s]{0,10}"#
        let regex = try? NSRegularExpression(pattern: pattern)
        if regex?.firstMatch(in: text, range: NSRange(location: 0, length: text.count)) != nil {
            return true
        } else {
            return false
        }
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
                Text("직장 정보 입력")
                    .foregroundColor(ColorManager.black600)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.bottom, 2)
                Divider()
                    .foregroundColor(ColorManager.black50)
                    .padding(.bottom, 8)
                VStack {
                    VStack {
                        TextField("0~10자, 빈칸입력시 비공개처리", text: $text)
                            .introspectTextField(customize: { textField in
                                DispatchQueue.main.async {
                                    textField.becomeFirstResponder()
                                }
                            })
                            .padding(.horizontal, 18)
                            .padding(.vertical, 14)
                    }
                    .background(ColorManager.black50)
                    .cornerRadius(12)
                    .padding(.bottom, 12)
                    Button {
                        onConfirm(text)
                        self.modalStatus = .none
                    } label: {
                        Text("확인")
                    }
                    .frame(height: 48)
                    .buttonStyle(MainButtonStyle(color: isCorrect ? ColorManager.blue :ColorManager.black150))
                    .disabled(!isCorrect)
                }
                .padding(.horizontal, 16)
                Spacer()
            }
            .padding(.vertical, 18)
            .frame(height: 196)
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(24)
            .padding(.horizontal, 40)
        }
    }
}


struct CompanyInputModal_Previews: PreviewProvider {
    static var previews: some View {
        CompanyInputModal(
            modalStatus: .constant(.company), onConfirm: {_ in })
    }
}
