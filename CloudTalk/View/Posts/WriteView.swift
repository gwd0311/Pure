//
//  WriteView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/01.
//

import SwiftUI

struct WriteView: View {
    
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel = WriteViewModel()
    @State private var image: UIImage?
    @State private var isLoading = false
    @State private var showImagePicker = false
    @State private var text = ""
    @State private var showTextPlaceHolder = true
    @State private var photoButtonText = "사진 추가"
    @State private var showPointAlert = false
    
    var body: some View {
        ScrollView {
            imageSelector
            textEditor
            
            selectedPhoto
            
            Spacer()
                .alert(isPresented: $showPointAlert) {
                    Alert(
                        title: Text("알림"),
                        message: Text("오늘 게시물 작성으로 50포인트가 지급되었어요!"),
                        dismissButton: .default(Text("확인"), action: {
                            // TODO: viewModel에서 50포인트 올리기 + lastPointDate update하기
                            isLoading = true
                            viewModel.getPoint {
                                isLoading = false
                                AuthViewModel.shared.fetchUser()
                                dismiss()
                            }
                            
                        })
                    )
                }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 18)
        .fullScreenCover(isPresented: $showImagePicker, content: {
            ImagePicker(image: $image)
        })
        .overlay(
            isLoading ? LoadingView() : nil
        )
        .customNavigationTitle("글 작성")
        .customNavBarItems(trailing: registerButton)
    }
    
    private var imageSelector: some View {
        Button {
            hideKeyboard()
            setPlaceHolder()
            if image == nil {
                showImagePicker.toggle()
                photoButtonText = "사진 변경"
            } else {
                showImagePicker.toggle()
            }
        } label: {
            HStack {
                Image("photo_blue")
                Text(photoButtonText)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(ColorManager.blue)
            }
            .frame(height: 52)
            .frame(maxWidth: .infinity)
            .background(ColorManager.blueLight)
            .cornerRadius(12)
        }
        .padding(.bottom, 4)
    }
    
    private var textEditor: some View {
        TextEditor(text: $text)
            .lineLimit(10)
            .autocorrectionDisabled(true)
            .frame(minHeight: 200, maxHeight: 300)
            .cornerRadius(18)
            .onTapGesture {
                showTextPlaceHolder = false
            }
            .padding(.bottom, 4)
            .overlay(
                Group {
                    if showTextPlaceHolder {
                        VStack(spacing: 0) {
                            HStack(spacing: 0) {
                                Text(viewModel.placeholderText)
                                    .foregroundColor(ColorManager.black200)
                                    .font(.system(size: 16))
                                Spacer()
                            }
                            .frame(height: 200)
                            .frame(maxWidth: .infinity)
                            Spacer()
                        }
                        .allowsHitTesting(false)
                    }
                }
            )
    }
    
    private var selectedPhoto: some View {
        VStack {
            if let image = image {
                ZStack(alignment: .topTrailing) {
                    Color.clear
                        .aspectRatio(contentMode: .fit)
                        .overlay(
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(maxWidth: .infinity)
                        )
                        .cornerRadius(14)
                        .clipShape(Rectangle())
                        .contentShape(Rectangle())
                        .allowsHitTesting(false)
                    Button {
                        self.image = nil
                    } label: {
                        Image("photo_delete")
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                .contentShape(Rectangle())
            }
        }
    }
    
    private var registerButton: some View {
        Button {
            // 글 등록 기능 구현
            Task {
                isLoading = true
                await viewModel.register(image: image, text: text)
                try? await Task.sleep(nanoseconds: 2_000_000_000)
                isLoading = false
                if !AuthViewModel.shared.isPointReceivedToday {
                    self.showPointAlert.toggle()
                } else {
                    dismiss()
                }
            }
        } label: {
            Text("등록")
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(text.isEmpty ? ColorManager.black200 : ColorManager.blue)
        }
        .disabled(text.isEmpty)
    }
    
    private func setPlaceHolder() {
        if text.isEmpty {
            showTextPlaceHolder = true
        }
    }
}

struct WriteView_Previews: PreviewProvider {
    static var previews: some View {
        WriteView()
    }
}
