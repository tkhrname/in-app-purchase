//
//  InterAdsViewController.swift
//  SubscriptionApp
//
//  Created by 渡邊丈洋 on 2019/06/12.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import UIKit
import GoogleMobileAds

class InterAdsViewController: UIViewController, GADInterstitialDelegate {

    var interstitial: GADInterstitial!
    var count = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let buy = UserDefaults.standard.object(forKey: "buy") {
            let count = buy as! Int
            if count == 1 {
            }
        } else {
            interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
            interstitial = createAndLoadInterstital()
        }
    }
    
    func createAndLoadInterstital() -> GADInterstitial {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        return interstitial
    }
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        if interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else {
            print("not yet")
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
