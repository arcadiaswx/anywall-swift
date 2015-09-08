
import Foundation
import CoreLocation
import Parse
import MapKit

class Post: NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var title: String
    var subtitle: String!
    var object: PFObject!
    var user: PFUser!
    var pinColor: MKPinAnnotationColor!
    var animatesDrop = true
    
    init(object: PFObject) {
        let geoPoint = object[Constants.AWParsePostLocationKey] as! PFGeoPoint
        self.coordinate = CLLocationCoordinate2D(latitude: geoPoint.latitude, longitude: geoPoint.longitude)
        self.title = object[Constants.AWParsePostTextKey] as! String
        self.subtitle = (object[Constants.AWParsePostUserKey] as! PFUser)[Constants.AWParsePostUsernameKey] as! String
        self.object = object
        self.user = object[Constants.AWParsePostUserKey] as! PFUser
    }
    
    init(coordinate: CLLocationCoordinate2D, andTitle title: String, andSubtitle subtitle: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
    }
    
    override func isEqual(object: AnyObject?) -> Bool {
        if !(object is Post) {
            return false
        }
        let post = object as! Post
        if self.object != nil && post.object != nil {
            return self.object?.objectId == post.object?.objectId
        } else {
            return self.title == post.title && self.subtitle == post.subtitle && self.coordinate.longitude == post.coordinate.longitude && self.coordinate.latitude == post.coordinate.latitude
        }
    }
    
    func setTitleAndSubtitleOutsideDistance(outside: Bool) {
        if outside {
            self.title = Constants.kAWWAllCantViewPost
            self.subtitle = nil
            self.pinColor = MKPinAnnotationColor.Red
        } else {
            self.title = self.object[Constants.AWParsePostTextKey] as! String
            self.subtitle = (self.object[Constants.AWParsePostUserKey] as! PFUser)[Constants.AWParsePostUsernameKey] as! String
            self.pinColor = MKPinAnnotationColor.Green
        }
    }
    
}