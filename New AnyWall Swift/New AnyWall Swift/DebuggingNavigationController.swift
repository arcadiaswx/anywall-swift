//
//  DebuggingNavigationController.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 8/30/15.
//  Copyright (c) 2015 Jerry Herrera. All rights reserved.
//

import UIKit

class DebuggingNavigationController: UINavigationController {

    override func viewDidLoad() {
        println("Post's Navigation Controller loaded")
    }
    
    deinit {
        println("Post's Navigation Controller Deinited")
    }

}
