//
//  IntroductionSheetView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/23.
//

import SwiftUI

struct IntroductionSheetView: View {
    
    let viewModel: RegistrationViewModel
    @State private var introduction = ""
    @State private var isComplete = false
    
    var isCorrect: Bool {
        let pattern = #"^[\S ]{2,25}$"#
        let regex = try? NSRegularExpression(pattern: pattern)
        if regex?.firstMatch(in: introduction, range: NSRange(location: 0, length: introduction.count)) != nil {
            return true
        } else {
            return false
        }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("소개") {
                    TextField("소개글 입력(2~25자)", text: $introduction)
                        .disabled(isComplete)
                }
                Button(isCorrect ? "완료하기" : "올바르지 않은 형식입니다.") {
                    closeKeyBoard()
                    isComplete.toggle()
                    viewModel.setIntroduction(introduction: introduction)
                }
                .disabled(!isCorrect)
            }
            .navigationTitle("소개글을 입력해주세요.")
            .onAppear {
                if let introduction = viewModel.introduction {
                    self.introduction = introduction
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

struct IntroductionSheetView_Previews: PreviewProvider {
    static var previews: some View {
        IntroductionSheetView(viewModel: RegistrationViewModel())
    }
}
