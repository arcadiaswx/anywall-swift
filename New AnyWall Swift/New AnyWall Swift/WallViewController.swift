
import UIKit
import MapKit
import CoreLocation
import Parse

class WallViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, PostCreateDataSource, SettingsControllerDelegate, WallPostsTableViewControllerDataSource {
    @IBOutlet var mapView: MKMapView!
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation? {
        get {
            if CLLocationManager.authorizationStatus() == .Denied { return nil }
            else { return locationManager.location }
        }
        set {
            if newValue == nil { return }
            positionCircleOverlay(newValue!)
            let filterDistance = Constants.AWDefaultFilterDistance
            queryForAllPostsNearLocationWithNearbyDistance(filterDistance)
            updatePostsForLocationWithNearbyDistance(filterDistance)
        }
    }
    var circleOverlay: MKCircle!
    var wallPostsTableVC: AWTableViewController!
    var mapPannedSinceLastLocationUpdate = false
    var allPosts = [Post]()
    var annotations = [MKAnnotation]()
    var pinsPlaced = true
    
    // MARK: - WallViewController Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadWallPostsTableViewController()
        configureNavBar()
        mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(37.332495, -122.029095), MKCoordinateSpanMake(0.008516, 0.021801))
        self.mapView.delegate = self
        self.locationManager.delegate = self
        self.mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 10.0 //lets see if this makes didUpdateLocation less heavy weight
    }
    
    func configureNavBar() {
        self.title = "AnyWall"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Post", style: UIBarButtonItemStyle.Plain, target: self, action: "postButtonSelected")
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Settings", style: UIBarButtonItemStyle.Plain, target: self, action: "settingsButtonSelected")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if let navigationCont = navigationController {
            navigationCont.navigationBarHidden = false
        }
        locationManager.startUpdatingLocation()
        if CLLocationManager.authorizationStatus() != .AuthorizedWhenInUse {
            locationManager.requestWhenInUseAuthorization()
        }
        centerMapAroundUser()
    }
    
    override func viewDidAppear(animated: Bool) {
        currentLocation = locationManager.location
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        locationManager.stopUpdatingLocation()
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
    }
    
    // MARK: - AWTableViewController    
    //need to implement datasource for wallPostsTableVC
    func loadWallPostsTableViewController() {
        //must set self as delegate of wallPostsTableVC
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        wallPostsTableVC = storyboard.instantiateViewControllerWithIdentifier("tableVC") as! AWTableViewController
        wallPostsTableVC.dataSource = self
        self.view.addSubview(wallPostsTableVC.view)
        self.addChildViewController(wallPostsTableVC)
        wallPostsTableVC.didMoveToParentViewController(self)
    }
    
    func currentLocationForTableViewController() -> CLLocation? {
        return currentLocation
    }
    
    // MARK: - Navigation Bar Button Actions
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
        print("post button pressed")
        //self.performSegueWithIdentifier("goToPostNC", sender: self)
    }
    
    //lc
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "goToPostNC" {
            let destNC = segue.destinationViewController as! DebuggingNavigationController
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
    
    // MARK: - SettingsControllerDelegate
    func returnToLogin() {
        if let nav = self.navigationController {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateViewControllerWithIdentifier("loginVC") as! LogInViewController
            nav.setViewControllers([loginVC], animated: true)
        }
    }

    // MARK: - CoreLocation
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == CLAuthorizationStatus.AuthorizedWhenInUse {
            locationManager.startUpdatingLocation()
            mapView.setCenterCoordinate(CLLocationCoordinate2DMake(currentLocation!.coordinate.latitude, currentLocation!.coordinate.longitude), animated: true)
        } else { locationManager.stopUpdatingLocation() }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        self.currentLocation = newLocation
    }
    
    // MARK: - MapView Delegate / MapView
    func mapView(mapView: MKMapView, rendererForOverlay overlay: MKOverlay)-> MKOverlayRenderer {
        //Note: only overlay we are using in this application is the circle overlay. Apple switched protocol definition to return non-optional
        let circleRenderer = MKCircleRenderer(circle: self.circleOverlay)
        circleRenderer.strokeColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.7)
        circleRenderer.fillColor = UIColor.darkGrayColor().colorWithAlphaComponent(0.2)
        circleRenderer.lineWidth = 1.0
        return circleRenderer
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation { return nil }
        
        let pinIdentifier = "CustomPinAnnotation"
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
    
    func centerMapAroundUser() {
        if let location = currentLocation {
            mapView.region = MKCoordinateRegionMake(CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude), MKCoordinateSpanMake(0.008516, 0.021801))
            positionCircleOverlay(location)
        }
    }
    
    func positionCircleOverlay(location: CLLocation) {
        if circleOverlay != nil {
            mapView.removeOverlay(circleOverlay)
            circleOverlay = nil
        }
        let filterDistance = Constants.AWDefaultFilterDistance
        circleOverlay = MKCircle(centerCoordinate: location.coordinate, radius: filterDistance)
        mapView.addOverlay(circleOverlay)
    }
    
    // MARK: - Parse
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
            if error != nil { return }
            var returnedPostsToAddToMap = [Post]()
            var allReturnedObjects = [Post]()
            for object in results as! [PFObject] {
                let newPost = Post(object: object)
                allReturnedObjects.append(newPost)
                if !self.allPosts.contains(newPost) { //if allPosts doesnt contain this a given result returned by the query, we append it to the returnedPostsToAddToMap array
                    returnedPostsToAddToMap.append(newPost)
                }
            }
            var postsToRemoveFromAllPostsBecauseTheyWereNotReturnedByQuery = [Post]()
            for post in self.allPosts {
                if !allReturnedObjects.contains(post) {
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
            self.allPosts = self.allPosts.filter( { element in !postsToRemoveFromAllPostsBecauseTheyWereNotReturnedByQuery.contains(element) } ) //if element isnt in postsToRemoveAllF... then it gets to stay in the array that gets returned to allPosts
            self.allPosts += returnedPostsToAddToMap
            
            self.pinsPlaced = true
            
        }
    }
    
    //parse
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
    
    //?
    @IBAction func testQuery(sender: AnyObject) {
        /*let query = PFQuery(className: Constants.AWParsePostsClassName)
        let res = query.findObjects()
        let size = countElements(res)
        println("\((res[size - 1] as PFObject)[Constants.AWParsePostTextKey])")*/
    }

    //post create delegate
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
