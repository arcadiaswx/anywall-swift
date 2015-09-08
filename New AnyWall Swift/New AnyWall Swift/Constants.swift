//
//  Constants.swift
//  New AnyWall Swift
//
//  Created by Jerry Herrera on 8/25/15.
//  Copyright (c) 2015 Jerry Herrera. All rights reserved.
//

import Foundation

struct Constants {
    static let AWParsePostsClassName = "Posts"
    static let AWParsePostTextKey = "text"
    static let AWParsePostUserKey = "user"
    static let AWParsePostLocationKey = "location"
    static let AWParsePostUsernameKey = "username"
    static let AWParsePostNameKey = "name"
    
    static let kAWFilterDistanceKey = "filterDistance"
    static let kAWLocationKey = "location"
    
    static let AWFilterDistanceDidChangeNotification = "AWFilterDistanceDidChangeNotification"
    static let AWCurrentLocationDidChangeNotification = "AWCurrentLocationDidChangeNotification"
    static let AWPostCreatedNotification = "AWPostCreatedNotification"
    
    static let kAWWAllCantViewPost = "Can't view post! Get closer."
    static let AWUserDefaultsFilterDistanceKey = "filterDisance"
    
    static func feetToMeters(feet: Double) -> Double {
        return feet * 0.3048
    }
    static func metersToFeet(meters: Double) -> Double {
        return meters * 3.281
    }
    static func metersToKilometers(meters: Double) -> Double {
        return meters / 1000.0
    }
    static let AWDefaultFilterDistance = 1000.0
    static let AWWallPostMaximumSearchDistance = 100.0 //in kilos
    static let AWWallPostsSearchDefaultLimit: Int = 20
    static let AWWallPostsSearchDefaultLimitUInt: UInt = 20
}