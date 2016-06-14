//
//  Tweet.swift
//  iQONTweetDisplay
//
//  Created by kiri on 2016/06/14.
//  Copyright © 2016年 kiri. All rights reserved.
//

import Foundation
import UIKit

class Tweet {
    let fullname: String
    let username: String
    let tweetText: String
    let timeStamp: String
    var avatar = UIImage()
    
    init(fullname: String, username: String, avatarURLString: String, tweetText: String, timeStamp: String) {
        self.fullname = fullname
        self.username = username
        self.tweetText = tweetText
        self.timeStamp = timeStamp
        self.avatar = downloadImageFromURL(avatarURLString)
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