//
//  Tweet.swift
//  iQONTweetDisplay
//
//  Created by kiri on 2016/06/14.
//  Copyright © 2016年 kiri. All rights reserved.
//

import UIKit
import SwiftyJSON

class Tweet {
    let fullname: String
    let username: String
    let tweetText: String
    let timeStamp: String
    var avatar = UIImage()
    
    init(jsonData: JSON) {
        self.fullname = jsonData["user"]["name"].stringValue
        self.username = jsonData["user"]["screen_name"].stringValue
        self.tweetText = jsonData["text"].stringValue
        self.timeStamp = jsonData["created_at"].stringValue
        self.avatar = downloadImageFromURL(jsonData["user"]["profile_image_url_https"].stringValue)
    }
    
    private func downloadImageFromURL(imageURLString: String) -> UIImage {
        let url = NSURL(string: imageURLString.stringByReplacingOccurrencesOfString("\\", withString: ""))
        let imageData = NSData(contentsOfURL: url!)
        var image = UIImage()
        if let data = imageData {
            if let img = UIImage(data: data) {
                image = img
            }
        }
        return image;
    }
}