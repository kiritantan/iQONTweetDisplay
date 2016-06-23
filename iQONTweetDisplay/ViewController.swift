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

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var collectionView: UICollectionView!
    private var myActivityIndicator: UIActivityIndicatorView!
    var accountStore = ACAccountStore()
    var twAccount: ACAccount?
    var tweets: [Tweet] = []
    var screenSize: CGSize!
    var statusBarHeight: CGFloat!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.selectTwitterAccount()
        statusBarHeight = UIApplication.sharedApplication().statusBarFrame.size.height
        screenSize = UIScreen.mainScreen().bounds.size
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout { flowLayout.estimatedItemSize = CGSizeMake(1, 1) }
        myActivityIndicator = UIActivityIndicatorView()
        myActivityIndicator.frame = CGRectMake(0, 0, 50, 50)
        myActivityIndicator.center = self.view.center
        myActivityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        myActivityIndicator.startAnimating()
        self.view.addSubview(myActivityIndicator)
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
            let query = "q=iQON&count=100"
            self.getTweets(self.parseStringToDictionary(query))
        }
    }
    
    private func getTweets(query: [NSObject: AnyObject]) {
        let URL = NSURL(string: "https://api.twitter.com/1.1/search/tweets.json")
        let request = SLRequest(forServiceType: SLServiceTypeTwitter,
                                requestMethod: .GET,
                                URL: URL,
                                parameters: query)
        request.account = twAccount
        request.performRequestWithHandler { (responseData, urlResponse, error) -> Void in
            if error != nil {
                self.presentViewController(self.createErrorAlert("ツイート検索が失敗しました。", type: .Alert), animated: true, completion: nil)
                print("error is \(error)")
            } else {
                let json = JSON(data: responseData)
                for aTweet in json["statuses"].array! {
                    self.tweets.append(Tweet(jsonData: aTweet))
                }
                if let query = json["search_metadata"]["next_results"].string {
                    if self.tweets.count < 1000 {
                        self.getTweets(self.parseStringToDictionary(query.stringByReplacingOccurrencesOfString("?", withString: "")))
                    }
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.collectionView.reloadData()
                    self.myActivityIndicator.stopAnimating()
                })
            }
        }
    }
    
    func createErrorAlert(errorMessage: String, type: UIAlertControllerStyle) -> UIAlertController {
        let alert: UIAlertController = UIAlertController(title: "エラー", message: errorMessage, preferredStyle:  type)
        let defaultAction: UIAlertAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler:{
            (action: UIAlertAction!) -> Void in
            self.myActivityIndicator.stopAnimating()
            
        })
        alert.addAction(defaultAction)
        return alert
    }
    
    func parseStringToDictionary(queryStr: String) -> [NSObject: AnyObject] {
        var parsedQuery: [NSObject: AnyObject] = [:]
        if queryStr.isEmpty {
            return parsedQuery
        }
        let queries = queryStr.componentsSeparatedByString("&").map({$0.componentsSeparatedByString("=")})
        for query in queries {
            parsedQuery[query[0]] = query[1]
        }
        return parsedQuery
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("customCell", forIndexPath: indexPath) as! CustomCell
        if tweets.count >= 10 {
            cell.setTweet(tweets[indexPath.row])
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tweets.count
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let textHeight = tweets[indexPath.row].tweetText.getTextSize(UIFont.systemFontOfSize(12),viewWidth: screenSize.width - 16).height
        return CGSize(width: screenSize.width, height: 80 + textHeight)
    }
}