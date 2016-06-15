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

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
    @IBOutlet weak var collectionView: UICollectionView!
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
                self.presentViewController(self.createErrorAlert("通信が失敗しました", type: .Alert), animated: true, completion: nil)
                print("error! \(error)")
                return
            }
            
            if !granted {
                self.presentViewController(self.createErrorAlert("アカウントの利用が許可されていません。\n設定からアカウントの利用を許可してください。", type: .Alert), animated: true, completion: nil)
                return
            }
            
            let accounts = self.accountStore.accountsWithAccountType(accountType) as! [ACAccount]
            if accounts.count == 0 {
                self.presentViewController(self.createErrorAlert("アカウントが設定されておりません。\n設定からアカウントを設定してください。", type: .Alert), animated: true, completion: nil)
                return
            }
            self.twAccount = accounts[0]
            self.getTweets()
        }
    }
    
    private func getTweets() {
        let URL = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")
        let param = ["q": "iQON", "count": "100"]
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: .GET,
                                URL: URL,
                                parameters: param)
        
        request.account = twAccount
        
        //1000件取得できるようにする
        request.performRequestWithHandler { (responseData, urlResponse, error) -> Void in
            if error != nil {
                self.presentViewController(self.createErrorAlert("ツイート検索が失敗しました。", type: .Alert), animated: true, completion: nil)
                print("error is \(error)")
            } else {
                let json = JSON(data: responseData)
                for aTweet in json["statuses"].array! {
                    self.tweets.append(Tweet(fullname: aTweet["user"]["name"].stringValue, username: aTweet["user"]["screen_name"].stringValue, avatarURLString: aTweet["user"]["profile_image_url_https"].stringValue, tweetText: aTweet["text"].stringValue, timeStamp: aTweet["created_at"].stringValue))
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                })
            }
        }
    }
    
    func createErrorAlert(errorMessage: String, type: UIAlertControllerStyle) -> UIAlertController {
        let alert: UIAlertController = UIAlertController(title: "エラー", message: errorMessage, preferredStyle:  type)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
        })
        alert.addAction(defaultAction)
        return alert
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("customCell", forIndexPath: indexPath) as! CustomCell
        if tweets.count >= 10 {
            cell.setTweet(tweets[indexPath.row])
        }
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if tweets.count >= 10 {
            return tweets.count
        }
        return 10
    }

}
