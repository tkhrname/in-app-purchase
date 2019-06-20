//
//  ViewController.swift
//  SubscriptionApp
//
//  Created by 渡邊丈洋 on 2019/06/12.
//  Copyright © 2019 渡邊丈洋. All rights reserved.
//

import UIKit
import GoogleMobileAds
import SwiftyStoreKit

class SwiftyStoreKitViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var imageArray = [UIImage]()
    var titleArray = [String]()
    
    var indexNumber = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titleArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.selectionStyle = .none
        cell.imageView?.image = self.imageArray[indexPath.row]
        cell.textLabel?.text = self.titleArray[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        indexNumber = indexPath.row
        performSegue(withIdentifier: "next", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "next" {
            let profileVC = segue.destination as? ProfileViewController
            profileVC?.profileImage = imageArray[indexNumber]
            profileVC?.userName = titleArray[indexNumber]
        }
    }

    @IBAction func add(_ sender: UIButton) {
        imageArray.append(UIImage(named: "profile")!)
        titleArray.append("tkwatanabe")
        tableView.reloadData()
    }
}

