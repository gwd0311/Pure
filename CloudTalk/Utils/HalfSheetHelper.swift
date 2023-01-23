//
//  HalfSheetHelper.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/20.
//

import SwiftUI
import UIKit

struct HalfSheetHelper<SheetView: View>: UIViewControllerRepresentable {
    
    var sheetView: SheetView
    @Binding var showSheet: Bool
    var onEnd: () -> Void
    
    let controller = UIViewController()
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        
        controller.view.backgroundColor = .clear
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        if showSheet {
            
            let sheetController = CustomHostingController(rootView: sheetView)
            
            sheetController.presentationController?.delegate = context.coordinator

            uiViewController.present(sheetController, animated: true)
        } else {
            // showSheet가 toggle되면 뷰를 닫기
            uiViewController.dismiss(animated: true)
        }
    }
    
    // On Dismiss
    class Coordinator: NSObject, UISheetPresentationControllerDelegate {
        
        var parent: HalfSheetHelper
        
        init(parent: HalfSheetHelper) {
            self.parent = parent
        }
        
        func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
            parent.showSheet = false
            parent.onEnd()
        }
        
    }
}

// HalfSheet로 구현하기 위한 커스텀 UIHostingController
class CustomHostingController<Content: View>: UIHostingController<Content> {
    
    override func viewDidLoad() {
        
        // 프로퍼티 세팅
        if let presentationController = presentationController as? UISheetPresentationController {
            
            presentationController.detents = [
                .medium()
            ]
            
            // grab 옵션
            presentationController.prefersGrabberVisible = true
        }
    }
    
}
