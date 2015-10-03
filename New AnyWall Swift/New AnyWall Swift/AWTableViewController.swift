
import UIKit
import Parse
import ParseUI

protocol WallPostsTableViewControllerDataSource {
    func currentLocationForTableViewController() -> CLLocation?
}

class AWTableViewController: PFQueryTableViewController {
    var noDataButton: UIButton!
    var dataSource: WallPostsTableViewControllerDataSource?
    
    override func viewDidLoad() {
        print("table view loaded")
    
        parseClassName = Constants.AWParsePostsClassName
        textKey = Constants.AWParsePostTextKey
        //paginationEnabled = true
        paginationEnabled = false
        objectsPerPage = Constants.AWWallPostsSearchDefaultLimitUInt
        pullToRefreshEnabled = true
        
        self.tableView.separatorColor = self.view.backgroundColor
        self.refreshControl?.tintColor = UIColor(red: 118.0/255.0, green: 117.0/255.0, blue: 117/225, alpha: 0.5)
        //must add the button
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.loadObjects()
    }

    override func queryForTable() -> PFQuery {
        let query = PFQuery(className: parseClassName!)
        if objects?.count == 0 { query.cachePolicy = PFCachePolicy.CacheThenNetwork }
        let currentLocation = dataSource!.currentLocationForTableViewController()
        if currentLocation == nil {
            print("didnt get location for table view query")
            return query
        } else {
            print("Did get location")
        }
        let filterDistance = Constants.AWDefaultFilterDistance
        let geoPoint = PFGeoPoint(latitude: currentLocation!.coordinate.latitude, longitude: currentLocation!.coordinate.longitude)
        query.whereKey(Constants.AWParsePostLocationKey, nearGeoPoint: geoPoint, withinKilometers: filterDistance)
        query.includeKey(Constants.AWParsePostUserKey)
        return query
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath, object: PFObject?) -> PFTableViewCell? {
        let reuseIdentifier = "post_cell"
        var cell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier) as? AnyWallTableViewCell
        if cell == nil {
            cell = UITableViewCell(style: .Subtitle, reuseIdentifier: reuseIdentifier) as? AnyWallTableViewCell
            if cell == nil {
                print("cell cannot be converted from uitableviewcell to anywalltableviewcell")
            }
        }
        cell?.updateFromPost(object!)
        return cell
    }
}
