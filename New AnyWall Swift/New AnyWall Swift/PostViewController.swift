//
//  PostViewController.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 8/24/15.
//  Copyright (c) 2015 Jerry Herrera. All rights reserved.
//

import UIKit
import Parse

protocol PostCreateDataSource {
    func locationForPostCreateViewController() -> CLLocation?
}

class PostViewController: UIViewController, UITextViewDelegate {
    var testString: String?
    var maxCharacterCount: Int!
    var delegate: PostCreateDataSource?
    @IBOutlet var characterCountLabel: UILabel!
    @IBOutlet var textView: UITextView!
    @IBOutlet var postButton: UIBarButtonItem!

    //get rid of gimmick
    override func viewDidLoad() {
        super.viewDidLoad()

        print("post VC loaded")
        print("postVC's test string = \(testString)")
        self.maxCharacterCount = 140 //in final version this will draw from ConfigManager
        textView.delegate = self
        self.updateCharacterCountLabel()
        self.checkCharacterCount()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.textView.becomeFirstResponder()
    }
    
    @IBAction func postPost(sender: AnyObject) { //sloppy implementation
        self.textView.resignFirstResponder()
        self.updateCharacterCountLabel()
        let isAcceptableAfterAutocorrect = self.checkCharacterCount()
        if !isAcceptableAfterAutocorrect {
            self.textView.becomeFirstResponder()
            return
        }
        
        //gonna need location and user implementation
        //guessing not fully implemented
        if let delegate = self.delegate {
            let location = delegate.locationForPostCreateViewController()
            if let _location = location {
                let currentCoordinate = _location.coordinate
                let geoPoint = PFGeoPoint(latitude: currentCoordinate.latitude, longitude: currentCoordinate.longitude)
                let user = PFUser.currentUser()
                let postObject = PFObject(className: Constants.AWParsePostsClassName)
                postObject[Constants.AWParsePostTextKey] = self.textView.text
                postObject[Constants.AWParsePostUserKey] = user //might crash here not sure if im online on iphone
                postObject[Constants.AWParsePostLocationKey] = geoPoint
                let readOnlyACL = PFACL()
                readOnlyACL.setPublicReadAccess(true)
                readOnlyACL.setPublicWriteAccess(false)
                postObject.ACL = readOnlyACL
                postObject.saveInBackgroundWithBlock {
                    (success, error) in
                    if error != nil {
                        print("error occured")
                        //alert view
                        return
                    }
                    if success {
                        print("saved")
                        //send notification - dispatch async
                    } else {
                        print("failed")
                    }
                }
                
                
            } else {
                print("no location, not posting")
                return
            }
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }


    
    
    @IBAction func cancelPost(sender: AnyObject) { //PSEUDO DISMISS - fully implement when pieces are connected
        
        /*if let nav = self.navigationController {
            let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("default") as UIViewController
            nav.setViewControllers([vc], animated: true)
        }*/
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func updateCharacterCountLabel() {
        let charCount = self.textView.text.length //really count is textView.text.length
        self.characterCountLabel.text = "\(charCount)/\(self.maxCharacterCount)"
        if charCount > maxCharacterCount || charCount == 0 {
            characterCountLabel.font = UIFont.boldSystemFontOfSize(characterCountLabel.font.pointSize)
        } else {
            characterCountLabel.font = UIFont.systemFontOfSize(characterCountLabel.font.pointSize)
        }
    }
    
    func textViewDidChange(textView: UITextView) {
        self.updateCharacterCountLabel()
        self.checkCharacterCount()
    }

    func setMaximumCharacterCount(newMax: Int) {
        maxCharacterCount = newMax
        self.updateCharacterCountLabel()
        self.checkCharacterCount()
    }
    
    func checkCharacterCount() -> Bool {
        var enabled = false
        let charCount = self.textView.text.length
        if charCount > 0 && charCount < self.maxCharacterCount {
            enabled = true
        }
        self.postButton.enabled = enabled
        return enabled
    }

    
    deinit {
        print("post VC deinited")
    }
}
