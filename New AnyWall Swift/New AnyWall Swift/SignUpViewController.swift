//
//  SignUpViewController.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 8/30/15.
//  Copyright (c) 2015 Jerry Herrera. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController {
    override func viewDidLoad() {
        println("sign up loaded")
    }
    
    @IBAction func closeSignUp(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit {
        println("sign up deinited")
    }
}
