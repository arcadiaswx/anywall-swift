//
//  LogInViewController.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 8/30/15.
//  Copyright (c) 2015 Jerry Herrera. All rights reserved.
//

import UIKit
import Parse

class LogInViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate {
    //skeleton implementation
    
    @IBOutlet var activityView: ActivityView!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.usernameField.delegate = self
        self.passwordField.delegate = self
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        tapGestureRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    override func viewWillAppear(animated: Bool) {
        if let navigation = self.navigationController {
            navigation.navigationBarHidden = true
        }
        activityViewVisible = false
        activityView.setUpView()
    }
    
    var activityViewVisible: Bool {
        get {
            return self.activityView.hidden
        }
        set {
            self.activityView.hidden = !newValue
            newValue ? self.activityView.activityIndicator.startAnimating() : self.activityView.activityIndicator.stopAnimating()
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.usernameField {
            self.passwordField.becomeFirstResponder()
        }
        if textField == self.passwordField {
            self.passwordField.resignFirstResponder()
            self.processEntries()
        }
        return true
    }
    
    func processEntries() {
        let username = self.usernameField.text
        let password = self.passwordField.text
        let noUserNameText = "username"
        let noPasswordText = "password"
        var errorText = "No "
        let errorTextJoin = " or "
        let errorTextEnding = " entered"
        var textError = false
        
        
        if count(username) == 0 || count(password) == 0 {
            textError = true
            
            if count(password) == 0 {
                self.passwordField.becomeFirstResponder()
            }
            if count(username) == 0 {
                self.usernameField.becomeFirstResponder()
            }
        }
        
        if count(username) == 0 {
            textError = true
            errorText += noUserNameText
        }
        if count(password) == 0 {
            textError = true
            if count(username) == 0 {
                errorText += errorTextJoin
            }
            errorText += noPasswordText
        }
        if textError {
            errorText += errorTextEnding
            let alertView = UIAlertView(title: errorText, message: "", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alertView.show()
            return
        }
        
        //everything was ok 
        self.activityViewVisible = true
        PFUser.logInWithUsernameInBackground(username, password: password) {
            (user, error) in
            self.activityViewVisible = false
            if let user_ = user {
                self.loggingIn()
            } else {
                var alertTitle: String?
                if error != nil {
                    let errorDict = error?.userInfo
                    let errorString = errorDict?["error" as NSObject] as? String
                    alertTitle = errorString
                } else {
                    alertTitle = "Couldnt log in\nthe username or password were wrong."
                }
                let alertView = UIAlertView(title: alertTitle ?? "Sommat went wrong", message: "", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "OK")
                alertView.show()
                
                self.usernameField.becomeFirstResponder()
            }
        }
    }
    
    @IBAction func logIn(sender: AnyObject) {
        self.dismissKeyboard()
        self.processEntries()
    }
    
    func loggingIn() {
        if let navigation = self.navigationController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let wallVC = storyboard.instantiateViewControllerWithIdentifier("wallVC") as! UIViewController
            navigation.setViewControllers([wallVC], animated: true)
        }
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
    }
}
