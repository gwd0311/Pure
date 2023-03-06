//
//  ServiceTermView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/24.
//

import SwiftUI

struct ServiceTermView: View {
    var body: some View {
        WebViewWithLoader(urlString: "https://sly-silk-9f7.notion.site/d7bcaf516e004e7f8134c2452c602066")
            .customNavigationTitle("서비스 이용약관")
    }
}

struct ServiceTermView_Previews: PreviewProvider {
    static var previews: some View {
        ServiceTermView()
    }
}
