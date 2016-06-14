//
//  ViewController.swift
//  iQONTweetDisplay
//
//  Created by kiri on 2016/06/13.
//  Copyright © 2016年 kiri. All rights reserved.
//

import UIKit
import Accounts
import Social

class ViewController: UIViewController {
    var accountStore = ACAccountStore()
    var twAccount: ACAccount?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectTwitterAccount()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    private func selectTwitterAccount() {
        
        let accountType = accountStore.accountTypeWithAccountTypeIdentifier(ACAccountTypeIdentifierTwitter)
        
        accountStore.requestAccessToAccountsWithType(accountType, options: nil) { (granted:Bool, error:NSError?) -> Void in
            if error != nil {
                print("error! \(error)")
                return
            }
            
            if !granted {
                print("error! Twitterアカウントの利用が許可されていません")
                return
            }
            
            let accounts = self.accountStore.accountsWithAccountType(accountType) as! [ACAccount]
            if accounts.count == 0 {
                print("error! 設定画面からアカウントを設定してください")
                return
            }
            self.twAccount = accounts[0]
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
