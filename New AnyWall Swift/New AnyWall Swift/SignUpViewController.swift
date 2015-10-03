//
//  SignUpViewController.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 8/30/15.
//  Copyright (c) 2015 Jerry Herrera. All rights reserved.
//

import UIKit
import Parse

protocol SignUpVCDelegate {
    func userSignedUp()
}

class SignUpViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    @IBOutlet var passwordAgainField: UITextField!
    @IBOutlet var createAccountViewButton: UIView!
    @IBOutlet var activityView: ActivityView2!
    
    var delegate: SignUpVCDelegate!
    
    var activityViewHidden: Bool = true {
        didSet {
            activityView.hidden = activityViewHidden
            !activityViewHidden ? self.activityView.activityViewIndicator.startAnimating() : self.activityView.activityViewIndicator.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        print("sign up loaded")
        
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        self.passwordAgainField.delegate = self
        self.activityView.setUpView()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "createAccountPushed")
        self.createAccountViewButton.addGestureRecognizer(tapGestureRecognizer)
        
        let dismissKeyboardTapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        self.view.addGestureRecognizer(dismissKeyboardTapGestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.usernameField.becomeFirstResponder()
        self.activityViewHidden = true
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.usernameField {
            self.passwordField.becomeFirstResponder()
        }
        if textField == self.passwordField {
            self.passwordAgainField.becomeFirstResponder()
        }
        if textField == self.passwordAgainField {
            self.passwordAgainField.resignFirstResponder()
            self.processEntries()
        }
        
        return true
    }
    
    func processEntries() {
        let username = self.usernameField.text
        let password = self.passwordField.text
        let passwordAgain = self.passwordAgainField.text
        var errorText = "Please "
        let usernameBlankText = "enter a username"
        let passwordBlankText = "enter a password"
        let joinText = ", and "
        let passwordMismatchText = "enter the same password twice"
        
        var textError = false
        
        if username?.length == 0 || password?.length == 0 || passwordAgain?.length == 0 {
            textError = true
            
            if passwordAgain?.length == 0 {
                self.passwordAgainField.becomeFirstResponder()
            }
            if password?.length == 0 {
                self.passwordField.becomeFirstResponder()
            }
            if username?.length == 0 {
                self.usernameField.becomeFirstResponder()
                errorText += usernameBlankText
            }
            
            if password?.length == 0 || passwordAgain?.length == 0 {
                if username?.length == 0 {
                    errorText += joinText
                }
                errorText += passwordBlankText
            }
        } else if password != passwordAgain {
            textError = true
            errorText += passwordMismatchText
            self.passwordField.becomeFirstResponder()
        }
        
        if textError {
            let alertView = UIAlertView(title: errorText, message: "", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alertView.show()
            return
        }
        
        //everything good so far
        activityViewHidden = false
        let user = PFUser()
        user.username = username
        user.password = password
        user.signUpInBackgroundWithBlock {
            (succeeded, error) in
            if error != nil {
                let alertView = UIAlertView(title: "Error signing up", message: "", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "OK")
                alertView.show()
                self.activityViewHidden = true
                self.usernameField.becomeFirstResponder()
                return
            }
            
            self.activityViewHidden = true
            self.dismissViewControllerAnimated(true, completion: nil)
            self.delegate.userSignedUp()
            
        }
        
        
        
        
        
    }
    
    func createAccountPushed() {
        print("pushed create account")
        self.dismissKeyboard()
        self.processEntries()
    }
    
    func dismissKeyboard() {
        print("dismisses keyboard")
        self.view.endEditing(true)
    }
    
    @IBAction func closeSignUp(sender: AnyObject) {
        self.dismissKeyboard()
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    deinit {
        print("sign up deinited")
    }
}

extension String {
    var length: Int {
        return NSString(string: self).length
    }
}
