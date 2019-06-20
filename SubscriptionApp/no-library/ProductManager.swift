//
//  ProductManager.swift
//  in-app-purchase
//
//  Created by Watanabe Takehiro on 2019/06/14.
//  Copyright © 2019 Watanabe Takehiro. All rights reserved.
//

import Foundation
import StoreKit

/// 価格情報取得エラー
public enum ProductManagerError: Error, CustomStringConvertible {
    
    case emptyProductIdentifiers
    case noValidProducts
    case notMatchProductIdentifier
    case skError(messaga: String)
    case unkown
    
    public var description: String {
        switch self {
        case .emptyProductIdentifiers:
            return "プロダクトIDが指定されていません。"
        case .noValidProducts:
            return "有効なプロダクトを取得できませんでした。"
        case .notMatchProductIdentifier:
            return "指定したプロダクトIDと取得したプロダクトIDが一致していません。"
        case .skError(let message):
            return message
        default:
            return "不明なエラー"
        }
    }
}

// 課金アイテム管理クラス
final public class ProductManager: NSObject {
    /// 保持用
    static private var managers: Set<ProductManager> = Set()
    /// 完了通知
    public typealias Completion = ([SKProduct], Error?) -> Void
    /// 完了通知
    public typealias CompletionForSingle = (SKProduct?, Error?) -> Void
    /// 完了通知用
    private var completion: Completion
    /// 価格問い合わせ用オブジェクト(保持用)
    private var productRequest: SKProductsRequest?
    /// 初期化
    private init(completion: @escaping Completion) {
        self.completion = completion
    }
    
    /// 課金アイテム情報を取得(複数)
    ///
    /// - Parameters:
    ///   - productIdentifiers: プロダクトID配列
    ///   - completion: 課金アイテム情報取得完了時の処理
    class func request(productIdentifiers: [String], completion: @escaping Completion) {
        guard !productIdentifiers.isEmpty else {
            completion([], ProductManagerError.emptyProductIdentifiers)
            return
        }
        
        let productManager = ProductManager(completion: completion)
        // SKProductsRequestのインスタンスを作成
        let productRequest = SKProductsRequest(productIdentifiers: Set(productIdentifiers))
        // SKProductsRequestDelegateを指定
        productRequest.delegate = productManager
        productRequest.start()
        // 要求オブジェクトへの強い参照を保持
        productManager.productRequest = productRequest
        managers.insert(productManager)
    }
    
    /// 課金アイテム情報を取得(1つ)
    ///
    /// - Parameters:
    ///   - productIdentifier: プロダクトID
    ///   - completion: 課金アイテム情報取得完了時の処理
    class func request(productIdentifier: String, completion: @escaping CompletionForSingle) {
        ProductManager.request(productIdentifiers: [productIdentifier]) { (products, error) in
            guard error == nil else {
                completion(nil, error)
                return
            }
            
            guard let product = products.first else {
                completion(nil, ProductManagerError.noValidProducts)
                return
            }
            
            guard product.productIdentifier == productIdentifier else {
                completion(nil, ProductManagerError.notMatchProductIdentifier)
                return
            }
            
            completion(product, nil)
        }
    }
}

extension ProductManager: SKProductsRequestDelegate {
    
    // Sent immediately before -requestDidFinish:
    public func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        let error = response.products.isEmpty ? ProductManagerError.noValidProducts : nil
        self.completion(response.products, error)
    }
    
    public func request(_ request: SKRequest, didFailWithError error: Error) {
        self.completion([], ProductManagerError.skError(messaga: error.localizedDescription))
        ProductManager.managers.remove(self)
    }
    
    public func requestDidFinish(_ request: SKRequest) {
        ProductManager.managers.remove(self)
    }
}


public extension SKProduct {
    /// 価格
    var localizedPrice: String? {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = priceLocale
        return numberFormatter.string(from: price)
    }
}
