//
//  UserInformation.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 2/2/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import Foundation

struct UserInformation {
    var firstName = ""
    var lastName = ""
    
    /* Construct a PublicUserInformation from a dictionary */
    init(dictionary: NSDictionary) {
        firstName = dictionary["first_name"] as! String
        lastName = dictionary["last_name"] as! String
    }
}