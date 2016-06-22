//
//  String.swift
//  iQONTweetDisplay
//
//  Created by kiri on 2016/06/20.
//  Copyright © 2016年 kiri. All rights reserved.
//

import UIKit

extension String {
    func getTextSize(font:UIFont, viewWidth:CGFloat) -> CGSize {
        let label = UILabel(frame: CGRectZero)
        label.numberOfLines = 0
        label.font = font
        label.lineBreakMode = .ByWordWrapping
        label.text = self
        return label.sizeThatFits(CGSizeMake(viewWidth, CGFloat.max))
    }
}