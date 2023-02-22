//
//  IntroductionModal.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/21.
//

import SwiftUI

struct IntroductionModal: View {
    
    @Binding var modalStatus: ModalStatus
    let onConfirm: (String) -> Void
    @State private var text: String = ""
    @State private var isEditing = false
    
    var isCorrect: Bool {
        let pattern = #"^[\S ]{1,25}$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        if regex?.firstMatch(in: text, range: NSRange(location: 0, length: text.count)) != nil {
            return true
        } else {
            return false
        }
    }
    
    init(modalStatus: Binding<ModalStatus>, onConfirm: @escaping (String) -> Void) {
        _modalStatus = modalStatus
        self.onConfirm = onConfirm
        UITextView.appearance().backgroundColor = .clear
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
                Text("내 소개 입력")
                    .foregroundColor(ColorManager.black600)
                    .font(.system(size: 18, weight: .semibold))
                    .padding(.bottom, 2)
                Divider()
                    .foregroundColor(ColorManager.black50)
                    .padding(.bottom, 8)
                VStack {
                    VStack {
                        ZStack {
                            TextEditor(text: $text)
                                .colorMultiply(ColorManager.black50)
                                .padding(.horizontal, 18)
                                .padding(.vertical, 14)
                            VStack {
                                HStack {
                                    Text(text.isEmpty ? "최대 25글자까지 입력해주세요." : "")
                                        .foregroundColor(ColorManager.black200)
                                        .padding(.leading, 24)
                                        .padding(.top, 23)
                                    Spacer()
                                }
                                Spacer()
                            }
                            .allowsHitTesting(false)
                        }
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
            .frame(height: 250)
            .frame(maxWidth: .infinity)
            .background(.white)
            .cornerRadius(24)
            .padding(.horizontal, 40)
        }
    }
}

struct IntroductionModal_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionModal(modalStatus: .constant(.introduction), onConfirm: { _ in })
    }
}
