//
//  NicknameSheetView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/23.
//

import SwiftUI

struct NicknameSheetView: View {
    
    let viewModel: RegistrationViewModel
    @State private var nickname = ""
    @State private var isComplete = false
    
    var isCorrect: Bool {
        let pattern = "^[A-Za-z가-힣]{2,6}$"
        let regex = try? NSRegularExpression(pattern: pattern)
        if regex?.firstMatch(in: nickname, range: NSRange(location: 0, length: nickname.count)) != nil {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("닉네임") {
                    TextField("닉네임 입력(2~6자, 특수문자 불가능)", text: $nickname)
                        .disabled(isComplete)
                }
                .accessibilityHint(Text("dd"))
                Button(isCorrect ? "완료하기" : "올바르지 않은 형식입니다.") {
                    closeKeyBoard()
                    isComplete.toggle()
                    viewModel.setNickName(nickname: nickname)
                }
                .disabled(!isCorrect)
            }
            .navigationTitle("닉네임을 입력해주세요.")
            .onAppear {
                if let name = viewModel.nickname {
                    self.nickname = name
                }
            }
        }
    }
    
    private func closeKeyBoard() {
        UIApplication.shared.sendAction(
          #selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil
        )
    }
}

struct NicknameSheetView_Previews: PreviewProvider {
    static var previews: some View {
        NicknameSheetView(viewModel: RegistrationViewModel())
    }
}
