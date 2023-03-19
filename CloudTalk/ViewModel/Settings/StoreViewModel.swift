//
//  StoreViewModel.swift
//  CloudTalk
//
//  Created by hanjongwoo on 2023/02/22.
//

import StoreKit
import Firebase

@MainActor
class StoreViewModel: NSObject, ObservableObject {
    
    @Published var products = [SKProduct]()
    @Published var currentPoint = AuthViewModel.shared.currentUser?.point ?? 0
    @Published var isLoading = false
    @Published var showFailAlert = false
    
    private let productIdentifiers: Set<String> = ["com.test.point1", "com.jerry.point2", "com.jerry.point3", "com.jerry.point4", "com.jerry.point5"]
    private var productRequest: SKProductsRequest?
    private var paymentQueue = SKPaymentQueue.default()
    
    override init() {
        super.init()
        self.paymentQueue.add(self)
    }
    
}

extension StoreViewModel: SKProductsRequestDelegate {
    func requestProducts() {
        self.productRequest = SKProductsRequest(productIdentifiers: self.productIdentifiers)
        self.productRequest?.delegate = self
        self.productRequest?.start()
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        DispatchQueue.main.async {
            self.products = response.products
        }
    }
}

extension StoreViewModel: SKPaymentTransactionObserver {
        
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                self.complete(transaction: transaction)
                print("구매했다.")
                isLoading = false
            case .restored:
                self.restore(transaction: transaction)
                print("복원했다.")
                isLoading = false
            case .failed:
                self.failed(transaction: transaction)
                print("실패했다.")
                isLoading = false
                showFailAlert = true
            case .deferred:
                self.deferred(transaction: transaction)
                isLoading = false
            case .purchasing:
                print("결제시트가 올라왔습니다.")
            @unknown default:
                fatalError()
            }
        }
    }
    
    func buy(product: SKProduct) {
        let payment = SKPayment(product: product)
        self.paymentQueue.add(payment)
    }
    
    func complete(transaction: SKPaymentTransaction) {
        self.paymentQueue.finishTransaction(transaction)
        // 구매 완료 처리
        addPoint(productID: transaction.payment.productIdentifier)
        print("구매가 완료되었습니다.")
    }
    
    func restore(transaction: SKPaymentTransaction) {
        self.paymentQueue.finishTransaction(transaction)
        // 복원 완료 처리
        print("복원이 완료되었습니다.")
    }
    
    func failed(transaction: SKPaymentTransaction) {
        if let error = transaction.error as? SKError, error.code != .paymentCancelled {
            // 실패 처리
            print("결제에 실패하였습니다.")
            print(error.localizedDescription)
        }
        self.paymentQueue.finishTransaction(transaction)
    }
    
    func deferred(transaction: SKPaymentTransaction) {
        // 보류 처리
        print("보류 처리되었습니다.")
    }
}

// MARK: - StoreView와 관련된 동작 처리
extension StoreViewModel {
    
    func buyPoint(productID: String) {
        print("구매버튼을 눌렀습니다.")
        isLoading = true
        if SKPaymentQueue.canMakePayments() {
            let paymentRequest = SKMutablePayment()
            paymentRequest.productIdentifier = productID
            SKPaymentQueue.default().add(paymentRequest)
        }
    }
    
    func addPoint(productID: String) {
        var point = 0
        if productID == "com.jerry.point1" {
            point = 1000
        } else if productID == "com.jerry.point2" {
            point = 3250
        } else if productID == "com.jerry.point3" {
            point = 6800
        } else if productID == "com.jerry.point4" {
            point = 12000
        } else if productID == "com.jerry.point5" {
            point = 25200
        } else {
            print("productID Error:: \(productID)")
            return
        }
        
        COLLECTION_USERS.document(AuthViewModel.shared.currentUser?.id ?? "").updateData([
            KEY_POINT: FieldValue.increment(Int64(point))
        ]) { _ in
            AuthViewModel.shared.fetchUser()
            self.currentPoint += point
        }
    }
}

// MARK: - SKPaymentQueueDelegate
extension StoreViewModel: SKPaymentQueueDelegate {
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        print("dfalksjdflkasjdflkjsadlkj")
        return true
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, didFinishWithError error: Error?) {
        if let error = error {
            // 결제 오류 처리
            print("결제에 실패하였습니다. 오류: \(error.localizedDescription)")
        } else {
            // 결제 완료 처리
            print("결제가 완료되었습니다.")
        }
    }
}
