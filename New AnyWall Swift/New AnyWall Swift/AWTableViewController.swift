//
//  AWTableViewController.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 8/31/15.
//  Copyright (c) 2015 Jerry Herrera. All rights reserved.
//

import UIKit
import Parse
import ParseUI

protocol WallPostsTableViewControllerDataSource {
    func currentLocationForTableViewController() -> CLLocation?
}

class AWTableViewController: PFQueryTableViewController {
    var noDataButton: UIButton!
    
    override func viewDidLoad() {
        println("table view loaded")
    
        //type of object to fetch
        self.parseClassName = Constants.AWParsePostsClassName
        //feild to display?
        self.textKey = Constants.AWParsePostTextKey
        self.paginationEnabled = true
        self.objectsPerPage = Constants.AWWallPostsSearchDefaultLimitUInt
        //set notification observers
        
        self.tableView.separatorColor = self.view.backgroundColor
        self.refreshControl?.tintColor = UIColor(red: 118.0/255.0, green: 117.0/255.0, blue: 117/225, alpha: 0.5)
        //must add the button
    }
    
    
    override func viewDidLayoutSubviews() {
        println("lets see if this prints before error")
    }
    
    deinit {
        println("table view deinited")
    }
}
