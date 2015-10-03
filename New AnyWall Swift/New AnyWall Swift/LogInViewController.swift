
import UIKit
import Parse

class LogInViewController: UIViewController, UITextFieldDelegate, UIAlertViewDelegate, SignUpVCDelegate {

    @IBOutlet var activityView: ActivityView!
    @IBOutlet var usernameField: UITextField!
    @IBOutlet var passwordField: UITextField!
    var activityViewVisible: Bool {
        get {
            return !self.activityView.hidden
        }
        set {
            self.activityView.hidden = !newValue
            newValue ? self.activityView.activityIndicator.startAnimating() : self.activityView.activityIndicator.stopAnimating()
        }
    }
    
    // MARK: - ViewController Life Cycle
    
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
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let identifier = segue.identifier {
            if identifier == "toSignUp" {
                let signUpVC = segue.destinationViewController as! SignUpViewController
                signUpVC.delegate = self
            }
        }
    }
    
    // MARK: - Logging In
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == self.usernameField { self.passwordField.becomeFirstResponder() }
        if textField == self.passwordField { self.passwordField.resignFirstResponder(); self.processEntries() }
        return true
    }
    
    //may have to hook this up again
    @IBAction func logInPressed(sender: AnyObject) {
        self.dismissKeyboard()
        self.processEntries()
    }
    
    func dismissKeyboard() {
        self.view.endEditing(true)
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
        
        if username?.length == 0 || password?.length == 0 {
            textError = true
            if password?.length == 0 { self.passwordField.becomeFirstResponder() }
            if username?.length == 0 { self.usernameField.becomeFirstResponder() }
        }
        if username?.length == 0 { errorText += noUserNameText }
        if password?.length == 0 {
            if username?.length == 0 { errorText += errorTextJoin }
            errorText += noPasswordText
        }
        if textError {
            errorText += errorTextEnding
            let alertView = UIAlertView(title: errorText, message: "", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alertView.show()
            return
        }
        
        //everything was ok 
        self.attemptToLogInWith(username!, andPassword: password!)
    }
    
    func attemptToLogInWith(username: String, andPassword password: String) {
        self.activityViewVisible = true
        PFUser.logInWithUsernameInBackground(username, password: password) {
            user, error in
            self.activityViewVisible = false
            if user != nil { self.loggingIn() }
            else {
                var alertTitle = ""
                if error != nil {
                    let errorDict = error!.userInfo
                    let errorString = errorDict["error"] as! String
                    alertTitle = errorString
                } else { alertTitle = "Couldnt log in: username or password was wrong" }
                let alertView = UIAlertView(title: alertTitle, message: "", delegate: self, cancelButtonTitle: nil, otherButtonTitles: "OK")
                alertView.show()
                self.usernameField.becomeFirstResponder()
            }
        }
    }
    
    func loggingIn() {
        if let navigation = self.navigationController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let wallVC = storyboard.instantiateViewControllerWithIdentifier("wallVC") as! WallViewController
            navigation.setViewControllers([wallVC], animated: true)
        }
    }
    
    // MARK: - SignUpVCDelegate
    
    func userSignedUp() { self.loggingIn() }
}
