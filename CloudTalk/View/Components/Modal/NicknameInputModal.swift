//
//  NicknameInputModal.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/20.
//

import SwiftUI
import Introspect

struct NicknameInputModal: View {
    
    @Binding var modalStatus: ModalStatus
    let onConfirm: (String) -> Void
    @State private var text: String = ""
    
    var isCorrect: Bool {
        let pattern = "^[A-Za-z가-힣]{2,6}$"
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
                Text("닉네임 입력")
                    .foregroundColor(ColorManager.black600)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.bottom, 2)
                Divider()
                    .foregroundColor(ColorManager.black50)
                    .padding(.bottom, 8)
                VStack {
                    VStack {
                        TextField("2~6자, 특수문자 불가능", text: $text)
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

struct NicknameInputModal_Previews: PreviewProvider {
    static var previews: some View {
        NicknameInputModal(modalStatus: .constant(.none), onConfirm: { _ in})
    }
}
