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
import SwiftyJSON

class ViewController: UIViewController {
    var accountStore = ACAccountStore()
    var twAccount: ACAccount?
    var tweets: [Tweet] = []

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
            self.getTweets()
        }
    }
    
    private func getTweets() {
        let URL = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")
        let param = ["q": "WIXOSS", "count": "100"]
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: .GET,
                                URL: URL,
                                parameters: param)
        
        request.account = twAccount
        
        //1000件取得できるようにする
        request.performRequestWithHandler { (responseData, urlResponse, error) -> Void in
            if error != nil {
                print("error is \(error)")
            } else {
                let json = JSON(data: responseData)
                for aTweet in json["statuses"].array! {
                    self.tweets.append(Tweet(fullname: aTweet["user"]["name"].stringValue, username: aTweet["user"]["screen_name"].stringValue, avatarURLString: aTweet["user"]["profile_image_url_https"].stringValue, tweetText: aTweet["text"].stringValue, timeStamp: aTweet["created_at"].stringValue))
                }
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
