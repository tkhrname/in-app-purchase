//
//  PurchaseManager.swift
//  in-app-purchase
//
//  Created by Watanabe Takehiro on 2019/06/14.
//  Copyright © 2019 Watanabe Takehiro. All rights reserved.
//

import Foundation
import StoreKit

enum PurchaseManagerError: Error, CustomStringConvertible {
    case cannotMakePayments
    case purchasing
    case restoreing
    case cannotConnectToItunesStore
    
    var description: String {
        switch self {
        case .cannotMakePayments:
            return "設定で購入が無効になっています。"
        case .purchasing:
            return "課金処理中です。"
        case .restoreing:
            return "リストア中です。"
        case .cannotConnectToItunesStore:
            return "Cannot connect to iTunes Store"
        }
    }
}

/// 課金するためのクラス
class PurchaseManager: NSObject {
    
    static var shared = PurchaseManager()
    
    weak var delegate: PurchaseManagerDelegate?
    
    private var productIdentifier: String?
    private var isRestore: Bool = false
    
    /// 課金開始
    ///
    /// - Parameters:
    ///   - product: プロダクト情報
    public func purchase(product: SKProduct){
        
        var error: PurchaseManagerError?
        // [canMakePayments]支払いの許可が有効か無効か判断
        if SKPaymentQueue.canMakePayments() == false {
            error = .cannotMakePayments
        }
        
        if productIdentifier != nil {
            error = .purchasing
        }
        
        if isRestore == true {
            error = .restoreing
        }
        
        //エラーがあれば終了
        if error != nil {
            delegate?.purchaseManager(self, didFailTransactionWithError: error)
            return
        }
        
        // 未処理のトランザクションがあればそれを利用
        // [SKPaymentTransaction] 支払い取引
        let transactions: [SKPaymentTransaction] = SKPaymentQueue.default().transactions
        for transaction in transactions {
            // ユーザーが課金済みの場合処理を継続、課金していない場合はスキップ -> 購入しているが取引が完了していない場合処理を実行する
            if transaction.transactionState != .purchased { continue }
            if transaction.payment.productIdentifier == product.productIdentifier {
                guard let window = UIApplication.shared.delegate?.window else { continue }
                let ac = UIAlertController(title: nil, message: "\(product.localizedTitle)は購入処理が中断されていました。\nこのまま無料でダウンロードできます。", preferredStyle: .alert)
                let action = UIAlertAction(title: "続行", style: UIAlertAction.Style.default, handler: {[weak self] (action : UIAlertAction!) -> Void in
                    if let strongSelf = self {
                        strongSelf.productIdentifier = product.productIdentifier
                        strongSelf.completeTransaction(transaction)
                    }
                })
                ac.addAction(action)
                window?.rootViewController?.present(ac, animated: true, completion: nil)
                return
            }
        }
        
        //課金処理開始
        // プロダクトオブジェクトを使用して支払い要求を作成
        let payment = SKMutablePayment(product: product)
        // 支払い要求の送信
        SKPaymentQueue.default().add(payment)
        productIdentifier = product.productIdentifier
    }
    
    /// リストア開始
    ///
    /// - Parameters:
    public func restore() {
        if isRestore == false {
            isRestore = true
            SKPaymentQueue.default().restoreCompletedTransactions()
        }else{
            // リストア処理中のため終了
            delegate?.purchaseManager(self, didFailTransactionWithError: PurchaseManagerError.restoreing)
        }
    }
    
    // MARK: - SKPaymentTransaction process
    
    /// トランザクション処理完了
    ///
    /// - Parameters:
    ///   - transaction: トランザクション情報
    private func completeTransaction(_ transaction : SKPaymentTransaction) {
        if transaction.payment.productIdentifier == self.productIdentifier {
            //課金終了
            delegate?.purchaseManager(self, didFinishTransaction: transaction, decisionHandler: { (complete) -> Void in
                if complete == true {
                    //トランザクション終了
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
            productIdentifier = nil
        }else{
            //課金終了(以前中断された課金処理)
            delegate?.purchaseManager(self, didFinishUntreatedTransaction: transaction, decisionHandler: { (complete) -> Void in
                if complete == true {
                    //トランザクション終了
                    SKPaymentQueue.default().finishTransaction(transaction)
                }
            })
        }
    }
    
    /// トランザクション処理完了
    ///
    /// - Parameters:
    ///   - transaction: トランザクション情報
    private func failedTransaction(_ transaction : SKPaymentTransaction) {
        //課金失敗
        delegate?.purchaseManager(self, didFailTransactionWithError: transaction.error)
        productIdentifier = nil
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    private func restoreTransaction(_ transaction : SKPaymentTransaction) {
        //リストア(originalTransactionをdidFinishPurchaseWithTransactionで通知)　※設計に応じて変更
        delegate?.purchaseManager(self, didFinishTransaction: transaction, decisionHandler: { (complete) -> Void in
            if complete == true {
                //トランザクション終了
                SKPaymentQueue.default().finishTransaction(transaction)
            }
        })
    }
    
    private func deferredTransaction(_ transaction : SKPaymentTransaction) {
        //承認待ち
        delegate?.purchaseManagerDidDeferred(self)
        productIdentifier = nil
    }
}

extension PurchaseManager : SKPaymentTransactionObserver {
    
    // 課金状態が更新されるたびに呼ばれる
    // 支払い要求に成功して変化した場合、StoreKitはAppのトランザクションキューのオブザーバを呼び出し
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchasing: // トランザクション処理中
                print("purchasing")
            case .purchased: // 購入完了
                print("purchased")
            case .failed: // 購入処理失敗
                guard let error = transaction.error else { return }
                print(error.nserror.code)
                print(error.nserror.domain)
                print(error.nserror.description)
            case .restored: // 以前にユーザーが購入したコンテンツを復元
                print("restored")
            case .deferred: // 許可を求める通知を発行した状態
                print("deferred")
            @unknown default:
                print("default")
            }
        }
    }
    
    // トランザクションがキューから削除されると呼び出されます。
    func paymentQueue(_ queue: SKPaymentQueue, removedTransactions transactions: [SKPaymentTransaction]) {
        print("removedTransactions")
    }
    
    // リストア完了時に呼ばれる
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        print("paymentQueueRestoreCompletedTransactionsFinished")
    }
    
    // リストア失敗時に呼ばれる
    func paymentQueue(_ queue: SKPaymentQueue, restoreCompletedTransactionsFailedWithError error: Error) {
        print("restoreCompletedTransactionsFailedWithError")
    }
    
//    paymentQueueRestoreCompletedTransactionsFinished
    func paymentQueue(_ queue: SKPaymentQueue, updatedDownloads downloads: [SKDownload]) {
        print("updatedDownloads")
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        print("shouldAddStorePayment")
        return false
    }
}

