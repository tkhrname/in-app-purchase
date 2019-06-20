//
//  ProfileViewController.swift
//  SubscriptionApp
//
//  Created by 渡邊丈洋 on 2019/06/12.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import UIKit

class ProfileViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    
    var profileImage = UIImage()
    var userName = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let buy = UserDefaults.standard.object(forKey: "buy") {
            let count = buy as! Int
            if count == 1 {
                imageView.image = UIImage(named: "anonymous")
                userNameLabel.text = "匿名ユーザー"
            }
        } else {
            imageView.image = profileImage
            userNameLabel.text = userName
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
}
