
import UIKit
import MapKit
import CoreLocation
import Parse

class WallViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, PostCreateDataSource, SettingsControllerDelegate {
    @IBOutlet var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation? {
        get {
            if CLLocationManager.authorizationStatus() == .Denied {
                println("currentLocation is currently nil")
                return nil
            } else {
                return locationManager.location
            }
        }
        set {
            if currentLocation == newValue {
                return
            }
            
            dispatch_async(dispatch_get_main_queue()) {
                println("did change location")
            }
            
            let filterDistance = Constants.AWDefaultFilterDistance
            //some fluff
            if self.circleOverlay != nil {
                self.mapView.removeOverlay(circleOverlay)
                self.circleOverlay = nil
            }
            self.circleOverlay = MKCircle(centerCoordinate: self.locationManager.location.coordinate, radius: filterDistance)
            self.mapView.addOverlay(circleOverlay)
            
            self.queryForAllPostsNearLocationWithNearbyDistance(filterDistance)
            self.updatePostsForLocationWithNearbyDistance(filterDistance)
        }
    }
    var circleOverlay: MKCircle!
    var wallPostsTableVC: AWTableViewController!
    var mapPannedSinceLastLocationUpdate = false
    var allPosts = [Post]()
    var annotations = [MKAnnotation]()
    var pinsPlaced = true
    

    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadWallPostsTableViewController()
        
        //nav bar elements
        self.title = "AnyWall"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Plain, target: self, action: "postButtonSelected")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain, target: self, action: "settingsButtonSelected")

        //set default mapRegion, may not even be necessary
        self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.332495, -122.029095), MKCoordinateSpanMake(0.008516, 0.021801))
        //this controller is pretty heavy weight, will handle protocol methods for both map and location manager
        self.mapView.delegate = self
        self.locationManager.delegate = self
        
        self.mapView.showsUserLocation = true //wonder if this works if we put it before startStandardUpdates
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        
        println("wallVC loaded")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationCont = self.navigationController {
            navigationCont.navigationBarHidden = false
        }
        
        self.locationManager.startUpdatingLocation()
        
        if let loc = currentLocation {
            self.mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(loc.coordinate.latitude, loc.coordinate.longitude), MKCoordinateSpanMake(0.008516, 0.021801))
            if self.circleOverlay != nil {
                mapView.removeOverlay(self.circleOverlay)
                self.circleOverlay = nil
            }
            
            let filterDistance = Constants.AWDefaultFilterDistance
            circleOverlay = MKCircle(centerCoordinate: loc.coordinate, radius: filterDistance)
            mapView.addOverlay(circleOverlay)
            
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        //queryForAllPostsNearLocationWithNearbyDistance(Constants.AWDefaultFilterDistance)
        self.currentLocation = self.locationManager.location
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        self.locationManager.stopUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let bounds = self.view.bounds
        var tableViewFrame = CGRectZero
        tableViewFrame.origin.x = 6.0
        tableViewFrame.origin.y = CGRectGetMaxY(self.mapView.frame) + 6
        tableViewFrame.size.width = CGRectGetMaxX(bounds) - CGRectGetMinX(tableViewFrame) * 2
        tableViewFrame.size.height = CGRectGetMaxY(bounds) - CGRectGetMaxY(tableViewFrame)
        self.wallPostsTableVC.view.frame = tableViewFrame
        //experiment
        self.wallPostsTableVC.tableView.hidden = true
    }
    
//WallPostTableViewController
    
    func loadWallPostsTableViewController() {
        //must set self as delegate of wallPostsTableVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        self.wallPostsTableVC = storyboard.instantiateViewControllerWithIdentifier("tableVC") as! AWTableViewController
        self.view.addSubview(self.wallPostsTableVC.view)
        self.addChildViewController(self.wallPostsTableVC)
        self.wallPostsTableVC.didMoveToParentViewController(self)
    }
    
//need to implement datasource for wallPostsTableViewController
    


//NavigationBar-based actions
    func settingsButtonSelected() {
        self.performSegueWithIdentifier("goToSettingsNC", sender: self)
    }
    
    func postButtonSelected() {
        //leaving this code so that you remember the programmatic method to segue
        /*let nc = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("postNC") as UINavigationController
        if let vcs = nc.viewControllers {
        //this code confirms that at this point in which we've instantiated the nav controller,
        //it has instantiated its rootVC and we can set its properties
        let vc = vcs[0] as PostViewController
        vc.testString = "Herpes"
        }
        self.presentViewController(nc, animated: true, completion: nil)*/
        
        //will try the segue approach
        self.performSegueWithIdentifier("goToPostNC", sender: self)
    }
    
    //get rid of gimmmick
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToPostNC" {
            let destNC = segue.destinationViewController as! UINavigationController
            let vcs = destNC.viewControllers
            let vc = vcs[0] as! PostViewController
            vc.delegate = self
            vc.testString = "Herpes"
        } else if segue.identifier == "goToSettingsNC" {
            let destNC = segue.destinationViewController as! UINavigationController
            destNC.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal
            let vcs = destNC.viewControllers
            let settingsController = vcs[0] as! SettingsViewController
            settingsController.wallControllerAsDelegate = self
        }
    }
    
    func returnToLogin() {
        if let nav = self.navigationController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let login = storyboard.instantiateViewControllerWithIdentifier("loginVC") as! UIViewController
            nav.setViewControllers([login], animated: true)
        }
    }

    //Done
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status != .Denied && status != .Restricted {
            locationManager.startUpdatingLocation()
            //set currentlocation
        } else {
            locationManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.currentLocation = newLocation
    }
    
    //Done
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        if error.code == 1 {
            self.locationManager.stopUpdatingLocation()
        } else if error.code == 0 { //location unknown - they didnt implement, and we may not either
            
        } else {
            let alert = UIAlertView(title: "Error retrieving location", message: error.localizedDescription, delegate: nil, cancelButtonTitle: nil, otherButtonTitles: "OK")
            alert.show()
        }
    }
    
//MapView Delegate
    func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
        if overlay is MKCircle {
            let circleRenderer = MKCircleRenderer(circle: self.circleOverlay)
            circleRenderer.strokeColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.7)
            circleRenderer.fillColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.2)
            circleRenderer.lineWidth = 1.0
            return circleRenderer
        }
        return nil
    }
    
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        if !(annotation is Post) {
            return nil
        }
        
        let pinIdentifier = "CustomPinAnnotation"
        
        println("\((annotation as! Post).title)")
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(pinIdentifier) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinIdentifier)
        } else {
            pinView?.annotation = annotation
        }
        pinView?.pinColor = (annotation as! Post).pinColor
        pinView?.animatesDrop = (annotation as! Post).animatesDrop
        pinView?.canShowCallout = true
            
        return pinView
        
    }
    
    //must fully implement
    func queryForAllPostsNearLocationWithNearbyDistance(nearbyDistance: CLLocationAccuracy) {
        let query = PFQuery(className: Constants.AWParsePostsClassName)
        if currentLocation == nil {
            return
        }
        if self.allPosts.count == 0 {
            query.cachePolicy = PFCachePolicy.CacheThenNetwork
        }
        let point = PFGeoPoint(location: self.currentLocation)
        query.whereKey(Constants.AWParsePostLocationKey, nearGeoPoint: point, withinKilometers:Constants.AWWallPostMaximumSearchDistance)
        query.includeKey(Constants.AWParsePostUserKey)
        query.limit = Constants.AWWallPostsSearchDefaultLimit
        
        query.findObjectsInBackgroundWithBlock {
            (results, error) in
            if error != nil {
                println("got an error querying")
                return
            }
            println("got \(results?.count)")
            var returnedPostsToAddToMap = [Post]()
            var allReturnedObjects = [Post]()
            for object in results as! [PFObject] {
                var newPost = Post(object: object)
                allReturnedObjects.append(newPost)
                if !contains(self.allPosts, newPost) { //if allPosts doesnt contain this a given result returned by the query, we append it to the returnedPostsToAddToMap array
                    returnedPostsToAddToMap.append(newPost)
                }
            }
            var postsToRemoveFromAllPostsBecauseTheyWereNotReturnedByQuery = [Post]()
            for post in self.allPosts {
                if !contains(allReturnedObjects, post) {
                    postsToRemoveFromAllPostsBecauseTheyWereNotReturnedByQuery.append(post)
                }
            }
            for newPost in returnedPostsToAddToMap {
                let postLocation = CLLocation(latitude: newPost.coordinate.latitude, longitude: newPost.coordinate.longitude)
                let distance = self.currentLocation?.distanceFromLocation(postLocation)
                newPost.setTitleAndSubtitleOutsideDistance(distance > nearbyDistance ? true : false)
                newPost.animatesDrop = self.pinsPlaced
            }
            
            self.mapView.removeAnnotations(postsToRemoveFromAllPostsBecauseTheyWereNotReturnedByQuery) // as! [MKAnnotation]
            self.mapView.addAnnotations(returnedPostsToAddToMap)
            
            /*let arr = [1, 4, 6, 78]
            let arr2 = [1, 3, 6, 9]
            let nsarr = NSMutableArray(array: arr as [Int])
            let nsarr2 = NSMutableArray(array: arr2 as [Int])
            nsarr.removeObjectsInArray(nsarr2 as [AnyObject])
            for element in nsarr {
            println(element)
            }*/  //we couldve done something like this but it wouldnt have been as simple, elegant, or as responsible with memory
            self.allPosts = self.allPosts.filter( { element in !contains(postsToRemoveFromAllPostsBecauseTheyWereNotReturnedByQuery, element) } ) //if element isnt in postsToRemoveAllF... then it gets to stay in the array that gets returned to allPosts
            self.allPosts += returnedPostsToAddToMap
            
            self.pinsPlaced = true
            
        }
    }
    
    func updatePostsForLocationWithNearbyDistance(nearbyDistance: CLLocationAccuracy) {
        for post in self.allPosts {
            let postLocation = CLLocation(latitude: post.coordinate.latitude, longitude: post.coordinate.longitude)
            let distanceFromCurrentLocation = currentLocation?.distanceFromLocation(postLocation)
            if distanceFromCurrentLocation > nearbyDistance {
                post.setTitleAndSubtitleOutsideDistance(true)
                (self.mapView.viewForAnnotation(post) as? MKPinAnnotationView)?.pinColor = MKPinAnnotationColor.Red
            } else {
                post.setTitleAndSubtitleOutsideDistance(false)
                (self.mapView.viewForAnnotation(post) as? MKPinAnnotationView)?.pinColor = MKPinAnnotationColor.Green
            }
        }
    }
    
    @IBAction func testQuery(sender: AnyObject) {
        /*let query = PFQuery(className: Constants.AWParsePostsClassName)
        let res = query.findObjects()
        let size = countElements(res)
        println("\((res[size - 1] as PFObject)[Constants.AWParsePostTextKey])")*/
    }
    
    deinit {
        println("wallVC deinited")
    }
    //what to do with this later
    func locationForPostCreateViewController() -> CLLocation? {
        return currentLocation
    }

}



//This code creates a user - we're going to place is somewhere else later
/*override func viewDidAppear(animated: Bool) {
let user = PFUser()
user.username = "gh"
user.password = "123"
user.signUpInBackgroundWithBlock {
(succeeded: Bool, error: NSError!) -> Void in
if error != nil {
println("There was an error")
return
} else {
println("new user signed up")
}
}
}*/


//logs in -> note that this code was experimental and we'll be moving it later
/*PFUser.logInWithUsername("gh", password: "123")
if let user = PFUser.currentUser() {
println("\(user.username)")
} else {
println("no user logged in")
}*/
