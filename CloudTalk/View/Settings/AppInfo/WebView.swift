//
//  WebView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/24.
//

import SwiftUI
import WebKit

struct WebViewWithLoader: View {
    let urlString: String
    @State var isLoading = true
    
    var body: some View {
        ZStack {
            WebView(urlString: urlString, isLoading: $isLoading)
                .opacity(isLoading ? 0 : 1) // 로딩중일 때는 웹뷰를 투명하게 표시
            if isLoading {
                ProgressView()
            }
        }
        .onAppear {
            isLoading = true // 로딩뷰를 보여주기 위해 isLoading 변수를 true로 설정
        }
        .onDisappear {
            isLoading = false // 웹뷰 로딩이 완료되면 isLoading 변수를 false로 설정
        }
    }
}

struct WebView: UIViewRepresentable {
    let urlString: String
    @Binding var isLoading: Bool
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView(frame: .zero, configuration: getConfiguration())
        webView.navigationDelegate = context.coordinator // navigationDelegate를 설정
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        if let url = URL(string: urlString) {
            let request = URLRequest(url: url)
            uiView.load(request)
        }
    }
    
    private func getConfiguration() -> WKWebViewConfiguration {
        let configuration = WKWebViewConfiguration()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        return configuration
    }
    
    // Coordinator 클래스를 구현하여 navigationDelegate 이벤트를 처리합니다.
    class Coordinator: NSObject, WKNavigationDelegate {
        let isLoading: Binding<Bool>
        
        init(_ isLoading: Binding<Bool>) {
            self.isLoading = isLoading
        }
        
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            isLoading.wrappedValue = false // 로딩이 완료되면 isLoading 변수를 false로 설정하여 로딩뷰를 제거합니다.
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($isLoading)
    }
}


