//
//  LogInViewController.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 8/30/15.
//  Copyright (c) 2015 Jerry Herrera. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController {
    //skeleton implementation
    @IBAction func logIn(sender: AnyObject) {
        PFUser.logInWithUsername("gh", password: "123")
        let user = PFUser.currentUser()
        println("\(user!.username) logged in")
        if let navigation = self.navigationController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewControllerWithIdentifier("wallVC") as! UIViewController
            navigation.setViewControllers([vc], animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //println("Login Did Load")
        if let navigation = self.navigationController {
            navigation.navigationBarHidden = true
        }
    }
    
    deinit {
        //println("Login Deinited")
    }

}
