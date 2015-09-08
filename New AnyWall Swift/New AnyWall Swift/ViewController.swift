//
//  ViewController.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 8/24/15.
//  Copyright (c) 2015 Jerry Herrera. All rights reserved.
//

import UIKit
import Parse

class ViewController: UIViewController {
    @IBAction func presentPostModally(sender: AnyObject) {
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("navCont") as? UIViewController {
                self.presentViewController(vc, animated: true, completion: nil)
            }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        let testObject = PFObject(className: "TestObject")
        testObject["foo"] = "bar"
        testObject.saveInBackgroundWithBlock { (success: Bool, error: NSError?) -> Void in
            println("Object has been saved.")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

