//
//  PrivacyPolicyView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/24.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        WebViewWithLoader(urlString: "https://sly-silk-9f7.notion.site/94f50b931d3947278034f7dc716e8bae")
            .customNavigationTitle("개인정보 처리방침")
    }
}

struct PrivacyPolicyView_Previews: PreviewProvider {
    static var previews: some View {
        PrivacyPolicyView()
    }
}
