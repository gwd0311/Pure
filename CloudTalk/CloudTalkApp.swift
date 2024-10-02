//
//  CloudTalkApp.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/01/18.
//

import SwiftUI
import FirebaseAuth
import FirebaseMessaging
import AppTrackingTransparency
import AdSupport
import GoogleMobileAds
import FirebaseCore

@main
struct CloudTalkApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var model: AuthViewModel
    
    init() {
        _model = StateObject(wrappedValue: AuthViewModel())

        if ATTrackingManager.trackingAuthorizationStatus == .notDetermined {
            // 사용자가 앱 추적에 대한 선택을 표시하지 않았습니다.
            // 데이터를 수집하는 이유를 설명하는 팝업을 표시할 수 있습니다.
            // 여기에서 이를 수행할 변수를 전환합니다.
            requestPermission()
        } else {
            ATTrackingManager.requestTrackingAuthorization { status in
                //Whether or not user has opted in initialize GADMobileAds here it will handle the rest
                print(ASIdentifierManager.shared().advertisingIdentifier.uuidString)
                GADMobileAds.sharedInstance().start()
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(model)
                .environmentObject(model.interstitialAd)
        }
    }
    
    private func delay() async {
        try? await Task.sleep(nanoseconds: 1_000_000_000)
    }
    
    private func requestPermission() {
        Task {
            await delay()
            ATTrackingManager.requestTrackingAuthorization { status in
                switch status {
                case .notDetermined:
                    print("notDetermined")
                case .restricted:
                    print("Restricted")
                case .denied:
                    print("Denied")
                case .authorized:
                    print("Authroized")
                    print(ASIdentifierManager.shared().advertisingIdentifier)
                @unknown default:
                    print("Unknown")
                }
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        FirebaseApp.configure()
        
        // 클라우드 메시징 세팅
        Messaging.messaging().delegate = self
        
        // UNUserNotification 세팅
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions,
            completionHandler: { _, _ in }
        )
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable: Any]) async
    -> UIBackgroundFetchResult {
        
        // 메시지 데이터와 함께 이곳에서 뭔가 하면된다.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        if let aps = userInfo["aps"] as? [String: Any], let badge = aps["badge"] as? Int {
            UIApplication.shared.applicationIconBadgeNumber = badge
        }
        
        // Print full message.
        print(userInfo)
        
        return UIBackgroundFetchResult.newData
    }
    
    // 알림을 받기위해서 이곳에서 메서드를 실행한다.
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let firebaseAuth = Auth.auth()
        firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
    }
    
}

// MARK: - 클라우드 메시징
extension AppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        
        // 이 토큰을 db에 저장하고 메시지 보낼때 되찾아야한다.
        let dataDict: [String: String] = ["token": fcmToken ?? ""]
        
        // 향후 서버에서 알림을 보내기 위해 Firestore에 토큰 저장...
        if let token = dataDict.first?.value {
            UserDefaults.standard.set(token, forKey: "token")
        } else {
            print("토큰이 없습니다.")
        }
    }
    
}

// MARK: - UNUserNotification 세팅
extension AppDelegate: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        completionHandler([[.banner, .badge,.sound]])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        
        print(userInfo)
        
        completionHandler()
    }
    
}
