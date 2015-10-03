//
//  ActivityView.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 9/8/15.
//  Copyright (c) 2015 Jerry Herrera. All rights reserved.
//

import UIKit

class ActivityView: UIView {

    @IBOutlet var label: UILabel!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    func setUpView() {
        self.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.95)
        self.label.textColor = UIColor.whiteColor()
        self.label.backgroundColor = UIColor.clearColor()
    }
}
