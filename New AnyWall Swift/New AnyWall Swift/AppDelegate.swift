
import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let parseID = "uA561AJhemBLj8QcFQzmuliSgHBxbaQvYysWAtEO"
    let parseKey = "LJ5cEZnqqpGhV2Y5gTFx2d7cjlbh2IcZualnrW1i"


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        Parse.setApplicationId(parseID, clientKey: parseKey)
        
        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        var initialVC: UIViewController!
        
        if PFUser.currentUser() != nil {
            initialVC = storyboard.instantiateViewControllerWithIdentifier("wallVC")
            print("App started. User is already logged in")
        } else {
            initialVC = storyboard.instantiateViewControllerWithIdentifier("loginVC")
            print("App started, user not logged in")
        }
        
        let navController = UINavigationController(rootViewController: initialVC)
        self.window?.rootViewController = navController
        window?.makeKeyAndVisible()
        return true
    }
}

