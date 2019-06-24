//
//  PurchaseViewModel.swift
//  SubscriptionApp
//
//  Created by 渡邊丈洋 on 2019/06/24.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import Foundation
import StoreKit

enum PurchaseViewModelState: CustomStringConvertible {
    
    case didFinishTransaction
    case didFinishUntreatedTransaction
    case didFailTransactionWithError
    case didFinishRestore
    case didDeferred
    
    var description: String {
        switch self {
        case .didFinishTransaction:
            return "purchase finish!"
        case .didFinishUntreatedTransaction:
            return "purchase finish!(Untreated.)"
        case .didFailTransactionWithError:
            return "purchase fail..."
        case .didFinishRestore:
            return "restore finish!"
        case .didDeferred:
            return "purcase defferd."
        }
    }
}

final class PurchaseViewModel {
    
    var stateDidUpdate: ((PurchaseViewModelState) -> Void)?
    
    func requestProduct(productIdentifiers: [String], completion: @escaping ProductManager.Completion) {
        ProductManager.request(productIdentifiers: productIdentifiers, completion: completion)
    }
    
    ///課金開始
    func purchase(productIdentifier: String) {
        // プロダクト情報取得
        ProductManager.request(productIdentifier: productIdentifier) { [weak self]  (product: SKProduct?, error: Error?) -> Void in
            guard error == nil, let product = product else {
                self?.purchaseManager(PurchaseManager.shared, didFailTransactionWithError: error)
                return
            }
            //デリゲード設定
            PurchaseManager.shared.delegate = self
            //課金処理開始
            PurchaseManager.shared.purchase(product: product)
        }
    }
    
    /// リストア開始
    private func startRestore() {
        //デリゲード設定
        PurchaseManager.shared.delegate = self
        //リストア開始
        PurchaseManager.shared.restore()
    }
    
}

extension PurchaseViewModel: PurchaseManagerDelegate {
    
    func purchaseManager(_ purchaseManager: PurchaseManager, didFinishTransaction transaction: SKPaymentTransaction, decisionHandler: (Bool) -> Void) {
        stateDidUpdate?(.didFinishTransaction)
        decisionHandler(true)
    }
    
    func purchaseManager(_ purchaseManager: PurchaseManager, didFinishUntreatedTransaction transaction: SKPaymentTransaction, decisionHandler: (Bool) -> Void) {
        stateDidUpdate?(.didFinishUntreatedTransaction)
        decisionHandler(true)
    }
    
    func purchaseManager(_ purchaseManager: PurchaseManager, didFailTransactionWithError error: Error?) {
        stateDidUpdate?(.didFailTransactionWithError)
    }
    
    func purchaseManagerDidFinishRestore(_ purchaseManager: PurchaseManager) {
        stateDidUpdate?(.didFinishRestore)
    }
    
    func purchaseManagerDidDeferred(_ purchaseManager: PurchaseManager) {
        stateDidUpdate?(.didDeferred)
    }
}
