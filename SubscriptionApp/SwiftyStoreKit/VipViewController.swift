//
//  VipViewController.swift
//  SubscriptionApp
//
//  Created by 渡邊丈洋 on 2019/06/12.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import UIKit
import SwiftyStoreKit

class VipViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func vipAction(_ sender: UIButton) {
        purchase(PRODUCT_ID: "")
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func restore(_ sender: UIButton) {
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
            case .success(let receiptData):
                let encryptedReceipt = receiptData.base64EncodedString(options: [])
                print("Fetch receipt success:\n\(encryptedReceipt)")
                // レシートの取得
                break
            case .error(let error):
                print(error)
                break
            }
        }
    }
    
    func purchase(PRODUCT_ID: String) {
        SwiftyStoreKit.purchaseProduct(PRODUCT_ID) { result in
            switch result {
            case .success(let purchase):
                print(purchase)
                // 購入が成功
                UserDefaults.standard.set(1, forKey: "buy")
                self.verifyPurchase(PRODUCT_ID: PRODUCT_ID)
                // 購入を検証
            case .error(let error):
                print(error)
                // 購入失敗
                break
            }
        }
    }
    
    func verifyPurchase(PRODUCT_ID: String) {
        let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: "")
        SwiftyStoreKit.verifyReceipt(using: appleValidator) { result in
            switch result {
            case .success(let receipt):
                // 自動更新
                let purchaseResult = SwiftyStoreKit.verifySubscription(ofType: .autoRenewable, productId: PRODUCT_ID, inReceipt: receipt)
                switch purchaseResult {
                    
                case .purchased(let expiryDate, let items):
                    print(expiryDate)
                    print(items)
                    UserDefaults.standard.set(1, forKey: "buy")
                    self.dismiss(animated: true, completion: nil)
                case .expired(let expiryDate, let items):
                    print(items)
                    print(expiryDate)
                    UserDefaults.standard.set(nil, forKey: "buy")
                    UserDefaults.standard.set(1, forKey: "check")
                    self.dismiss(animated: true, completion: nil)
                case .notPurchased:
                    break
                }
                break
            case .error(let error):
                print(error)
                break
            }
        }
    }
}
