//
//  MailView.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/23.
//

import Combine
import Foundation
import MessageUI
import SwiftUI

struct EmailSender: UIViewControllerRepresentable {
  @Environment(\.presentationMode) var presentationMode

  func makeUIViewController(context: Context) -> MFMailComposeViewController {
    let mail = MFMailComposeViewController()
    let contents = """
    아래에 문의하실 내용을 말씀해주세요.
    
    
    
    ------------------------------------------
    ID: \(AuthViewModel.shared.currentUser?.id ?? "")
    Model: \(UIDevice.current.name)
    Version: iOS \(UIDevice.current.systemVersion)
    """

    mail.setSubject("문의제목")
    mail.setToRecipients(["gwd0311@naver.com"])
    mail.setMessageBody(contents, isHTML: false)

    // delegate 채택
    mail.mailComposeDelegate = context.coordinator
    return mail
  }

  func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

  typealias UIViewControllerType = MFMailComposeViewController

  class Coordinator: NSObject, MFMailComposeViewControllerDelegate, UINavigationControllerDelegate {
    var parent: EmailSender

    init(_ parent: EmailSender) {
      self.parent = parent
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {

      controller.dismiss(animated: true, completion: nil)
    }
  }

  func makeCoordinator() -> Coordinator {
    Coordinator(self)
  }
}
