
import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId("?",
            clientKey: "?")
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var initialVC: UIViewController!
        
        if PFUser.currentUser() != nil {
            initialVC = storyboard.instantiateViewControllerWithIdentifier("wallVC") as! UIViewController
            println("App started. User is already logged in")
        } else {
            initialVC = storyboard.instantiateViewControllerWithIdentifier("loginVC") as! UIViewController
            println("App started, user not logged in")
        }
        
        var navController = UINavigationController(rootViewController: initialVC)
        self.window?.rootViewController = navController
        window?.makeKeyAndVisible()
        return true
    }
}

