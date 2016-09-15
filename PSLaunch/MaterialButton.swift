//
//  MaterialButton.swift
//  PSLaunch
//
//  Created by Jose Ponce on 9/13/16.
//  Copyright © 2016 http://www.poncesolutions.com All rights reserved.
//  This class is to give it rounded corners and  little shadow to the button.

import UIKit

class MaterialButton: UIButton {
    let SHADOW_COLOR: CGFloat = 157.0 / 255.0

    
    override func awakeFromNib() {
        layer.cornerRadius = 5.0
        layer.shadowColor = UIColor(red: SHADOW_COLOR, green: SHADOW_COLOR, blue: SHADOW_COLOR, alpha: 0.5).CGColor
        layer.shadowOpacity = 0.8
        layer.shadowRadius = 5.0
        layer.shadowOffset = CGSizeMake(0.0, 2.0)
    }
    
}
