//
//  ViewController.swift
//  SubscriptionApp
//
//  Created by 渡邊丈洋 on 2019/06/19.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import UIKit
import StoreKit

class ViewController: UIViewController {
    
    private var viewModel: PurchaseViewModel!
    
    let productIdentifiers = ["12345"]
    
    @IBOutlet weak var label: UILabel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.viewModel = PurchaseViewModel()
        self.viewModel.stateDidUpdate = { state in
            self.showAlert(state: state)
        }
        //プロダクト情報取得
        self.viewModel.requestProduct(productIdentifiers: productIdentifiers) { [weak self] (products: [SKProduct], error: Error?) -> Void in
            guard error == nil else {
                let text = (error as? ProductManagerError)?.localizedDescription ?? "error"
                self?.label?.text = text
                print(text)
                return
            }
            
            for product in products {
                //価格を抽出
                let priceString = product.localizedPrice ?? "--"
                /* TODO: UI更新 */
                let text = product.localizedTitle + " : \(priceString)"
                self?.label?.text = text
                print(text)
            }
        }
        
    }
    
    ///課金開始アクション
    @IBAction func didTapPurchaseButton(_ sender: UIButton!) {
        //課金開始（サンプルでは"productIdentifier1"決め打ちで）
        guard let productIdentifier = productIdentifiers.first else { return }
        self.viewModel.purchase(productIdentifier: productIdentifier)
    }
    
    private func showAlert(state: PurchaseViewModelState) {
        let ac = UIAlertController(title: state.description, message: nil, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(ac, animated: true, completion: nil)
    }
    
}
