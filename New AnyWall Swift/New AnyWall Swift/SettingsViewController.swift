//
//  SettingsViewController.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 8/31/15.
//  Copyright (c) 2015 Jerry Herrera. All rights reserved.
//

import UIKit
import Parse

protocol SettingsControllerDelegate {
    func returnToLogin()
}

class SettingsViewController: UIViewController {
    var wallControllerAsDelegate: SettingsControllerDelegate?
    
    @IBAction func dismissSettings(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func presentLogIn(sender: AnyObject) {
        PFUser.logOut()
        if let user = PFUser.currentUser() {
            println("this isnt supposed to print")
        } else {
            println("user logged out")
        }
        self.dismissViewControllerAnimated(false, completion: nil)
        wallControllerAsDelegate?.returnToLogin()
    }
    
    override func viewDidLoad() {
        println("settings loaded")
    }
    
    deinit {
        println("settings deinited")
    }

}
