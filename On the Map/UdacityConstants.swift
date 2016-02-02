//
//  UdacityConstants.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 2/2/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import Foundation

extension UdacityClient {
    
    // MARK: - Constants
    struct Constants {
        // BaseURL
        static let UdacityBaseURL: String = "https://www.udacity.com/api/"
        static let ParseBaseURL: String = "https://api.parse.com/1/classes/StudentLocation"
        
        // Parse app id and api key
        static let parseAppId: String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let parseApiKey: String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    // MARK: - Request to server
    struct RequestToServer {
        static let udacity : String = "udacity"
        static let parse : String = "parse"
    }
    
    // MARK: - Methods
    struct Methods {
        // get udacity session 
        static let CreateSession : String = "session"
        // get public users data
        static let Users : String = "users/"
        // parse limit
        static let limit : String = ""
    }
    
    // MARK: - JSON Body Keys
    struct JSONBodyKeys {
        // udacity
        static let Udacity = "udacity"
        static let Username = "username"
        static let Password = "password"
        
        // parse
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaURL = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
    }
    
    // MARK: - JSON Response Keys
    struct JSONResponseKeys {
        static let Error = "error"
        static let Status = "status"
        
        // MARK: Student information
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let MediaUrl = "mediaURL"
    }
}