//
//  User.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 1/31/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import Foundation

class User {
    
    static var username = ""
    static var key = ""
    static var sessionId = ""
    static var loading = true
    static var firstName = ""
    static var lastName = ""
    
    static var errors: [NSError] = []
    
    class func logIn(username: String, password: String, didComplete: (success: Bool, errorMessage: String?) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let udacityBody: [String:AnyObject] = ["username": username, "password": password]
        let jsonBody : [String:AnyObject] = ["udacity": udacityBody]
        
//        do {
            request.HTTPBody = try! NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
//        } catch {
//            didComplete(success: false, errorMessage: "Request Error")
//        }
        
//        let bodyString = "{\"udacity\": {\"username\": \"\(username)\", \"password\": \"\(password)\"}}"
//        request.HTTPBody = bodyString.dataUsingEncoding(NSUTF8StringEncoding)

        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            guard (error == nil) else {
                self.errors.append(error!)
                didComplete(success: false, errorMessage: "Network Error")
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            let success = User.parseUserData(newData)
            let errorMessage: String? = success ? nil : "Email or password was not valid"
            didComplete(success: success, errorMessage: errorMessage)
        }
        task.resume()
    }
    
    class func parseUserData(data: NSData) -> Bool {
        
        var success = true
        
        if let userData = (try? NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers)) as? NSDictionary,            let accout = userData["account"] as? [String : AnyObject],
            let session = userData["session"] as? [String : String] {
                User.key = accout["key"] as! String
                User.sessionId = session["id"]!
                User.getUserDetail({ (success) -> Void in
                    if success {
                        self.loading = false
                    }
                })
        } else {
            success = false
        }
        return success
    }
    
    class func getUserDetail(didComplete: (success: Bool) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/users/\(User.key)")!)
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            guard (error == nil) else {
                self.errors.append(error!)
                didComplete(success: false)
                return
            }
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            
            if let userData = (try? NSJSONSerialization.JSONObjectWithData(newData, options: .MutableContainers)) as? NSDictionary,
                let user = userData["user"] as? [String: AnyObject],
                let firstName = user["first_name"] as? String,
                let lastName = user["last_name"] as? String {
                self.firstName = firstName
                self.lastName = lastName
                    didComplete(success: true)
            }
        }
        task.resume()
    }
    
    class func logOut(didComplete: (success: Bool) -> Void) {
        
        let request = NSMutableURLRequest(URL: NSURL(string: "https://www.udacity.com/api/session")!)
        request.HTTPMethod = "DELETE"
        
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        
        for cookie in sharedCookieStorage.cookies! as [NSHTTPCookie] {
            if cookie.name == "XSRF-TOKEN" {
                xsrfCookie = cookie
            }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) -> Void in
            
            guard (error == nil) else {
                self.errors.append(error!)
                didComplete(success: false)
                return
            }
            
            _ = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
            didComplete(success: true)
        }
        task.resume()
    }
}
