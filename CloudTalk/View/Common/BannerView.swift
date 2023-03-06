//
//  BannerView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/03/02.
//

import SwiftUI
import GoogleMobileAds

// test: ca-app-pub-3940256099942544/2934735716
// oper: ca-app-pub-6301096399153807/8177497632

final class AdaptiveBannerViewController: UIViewController {

    private var adView: GADBannerView!

    override func viewDidLoad() {
        super.viewDidLoad()
        adView = GADBannerView(adSize: GADAdSize())
        adView.adUnitID = "ca-app-pub-6301096399153807/8177497632"
        adView.rootViewController = self
        view.addSubview(adView)
        adView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            adView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            adView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            adView.widthAnchor.constraint(equalTo: view.widthAnchor),
            adView.heightAnchor.constraint(equalToConstant: 58)
        ])
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
            self.adView.load(GADRequest())
        })
        
    }

}

struct AdaptiveBanner: UIViewControllerRepresentable {

    func makeUIViewController(context: Context) -> AdaptiveBannerViewController {
        AdaptiveBannerViewController()
    }

    func updateUIViewController(_ uiViewController: AdaptiveBannerViewController, context: Context) {}
}
