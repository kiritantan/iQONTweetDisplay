//
//  CustomCell.swift
//  iQONTweetDisplay
//
//  Created by kiri on 2016/06/15.
//  Copyright © 2016年 kiri. All rights reserved.
//

import UIKit

class CustomCell: UICollectionViewCell {
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    func setTweet(tweet: Tweet) {
        iconImageView.image = tweet.avatar
        fullNameLabel.text = tweet.fullname
        userNameLabel.text = "@" + tweet.username
        tweetTextLabel.text = tweet.tweetText
        timeStampLabel.text = tweet.timeStamp
    }
}