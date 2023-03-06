//
//  SendMessageView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/07.
//

import SwiftUI
import Kingfisher

struct SendMessageView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: SendMessageViewModel
    let onDimiss: () -> Void
    @State private var text = ""
    @State private var isLoading = false
    @State private var showPointAlert = false
    @State private var showStoreView = false
    
    var body: some View {
        let user = viewModel.user
        VStack(spacing: 0) {
            Spacer()
            profileImage
                .padding(.bottom, 14)
            HStack(spacing: 4) {
                Text(user.nickname)
                    .foregroundColor(ColorManager.blue)
                    .font(.system(size: 18, weight: .bold))
                Text("\(user.age)세 \(user.gender.title)")
                    .foregroundColor(ColorManager.black200)
                    .font(.system(size: 18, weight: .bold))
            }
            .padding(.bottom, 10)
            Text("50포인트로 대화를 시작해보세요!")
                .foregroundColor(ColorManager.black400)
                .font(.system(size: 15, weight: .light))
            CustomNavigationLink(
                destination: { StoreView() } ,
                isActive: $showStoreView,
                label: { Text("").hidden() }
            )
            Spacer()
            messageInputSection
        }
        .alert(isPresented: $showPointAlert, content: {
            Alert(
                title: Text("포인트 부족"),
                message: Text("포인트가 부족합니다. 스토어로 이동하시겠습니까?"),
                primaryButton: .default(Text("예"), action: {
                    // TODO: StoreView Sheet 띄우기
                    self.showStoreView.toggle()
                }),
                secondaryButton: .cancel(Text("아니오"), action: {
                    self.showPointAlert.toggle()
                })
            )
        })
        .customNavigationTitle(user.nickname)
        .customNavBarItems(trailing: Image("more").hidden())
    }
    
    private var profileImage: some View {
        Group {
            if !viewModel.user.profileImageUrl.isEmpty {
                Color.clear
                    .aspectRatio(contentMode: .fill)
                    .overlay(
                        KFImage(URL(string: viewModel.user.profileImageUrl))
                            .resizable()
                            .scaledToFill()
                    )
                    .frame(width: 74, height: 74)
                    .clipShape(Rectangle())
                    .contentShape(Rectangle())
                    .cornerRadius(16)
            } else if viewModel.user.gender == .man {
                Image("man")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 74, height: 74)
                    .clipShape(Rectangle())
                    .contentShape(Rectangle())
                    .cornerRadius(16)
            } else {
                Image("woman")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 74, height: 74)
                    .clipShape(Rectangle())
                    .contentShape(Rectangle())
                    .cornerRadius(16)
            }
        }
    }
    
    private var messageInputSection: some View {
        VStack(spacing: 0) {
            Rectangle()
                .foregroundColor(ColorManager.black50)
                .frame(height: 1)
            HStack(spacing: 0) {
                TextField("새 메시지 입력", text: $text)
                Spacer()
                Button {
                    Task {
                        isLoading = true
                        if await viewModel.checkPoint() {
                            await viewModel.setChats(text: text)
                            self.text = ""
                            hideKeyboard()
                            onDimiss()
                            dismiss()
                        } else {
                            // TODO: Alert 띄우기
                            self.showPointAlert.toggle()
                        }
                        isLoading = false

                    }
                } label: {
                    if text.isEmpty {
                        Image("sendBtn_off")
                    } else {
                        Image("sendBtn_on")
                    }
                }
                .disabled(text.isEmpty)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 10)
        }
    }
}

struct SendMessageView_Previews: PreviewProvider {
    static var previews: some View {
        SendMessageView(viewModel: SendMessageViewModel(user: MOCK_USER), onDimiss: {})
    }
}
