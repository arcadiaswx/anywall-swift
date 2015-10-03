//
//  AnyWallTableViewCell.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 10/2/15.
//  Copyright © 2015 Jerry Herrera. All rights reserved.
//

import UIKit
import ParseUI
import Parse

class AnyWallTableViewCell: PFTableViewCell {
    
    func updateFromPost(object: PFObject) {
        if let text = object[Constants.AWParsePostTextKey] as? String {
            self.textLabel?.text = text
        }
        if let username = (object[Constants.AWParsePostUserKey] as? PFUser)?[Constants.AWParsePostUsernameKey] as? String {
            self.detailTextLabel?.text = username
        }
    }
}
