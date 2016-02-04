//
//  UdacityConvenience.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 2/2/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import UIKit
import Foundation
import MapKit

// MARK: - Convenient Resource Methods

extension UdacityClient {
    
    // MARK: - POST Convenience Methods
    
    func userLogin(email: String, password: String, completionHandler: (result: String?, error: NSError?) -> Void) {
        
        // method
        
        let parameters : [String:String] = [
            UdacityClient.JSONBodyKeys.Username: email,
            UdacityClient.JSONBodyKeys.Password: password
        ]
        
        let jsonBody : [String:AnyObject] = [
            UdacityClient.JSONBodyKeys.Udacity: parameters
        ]
        
        // make the request
        _ = taskForPOSTMethod(UdacityClient.RequestToServer.udacity, method: Methods.CreateSession, parameters: parameters, jsonBody: jsonBody, subdata: 5) { (result, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            else {
                if let errorMsg = result.valueForKey(UdacityClient.JSONResponseKeys.Error)  as? String {
                    completionHandler(result: nil, error: NSError(domain: "udacity login issue", code: 0, userInfo: [NSLocalizedDescriptionKey: errorMsg]))
                }
                else {
                    let session = result["account"] as! NSDictionary
                    let key = session["key"] as! String
                    completionHandler(result: key, error: nil)
                }
            }
        }
    }
    
    // download student locations
    func getStudentLocations(completionHandler: (result: [StudentInformation]?, error: NSError?) -> Void) {
        
        // make the request
        
        _ = taskForGETMethod(UdacityClient.RequestToServer.parse, method: Methods.limit, parameters: ["limit":500]) { (result, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            else {
                if let locations = result as? [NSObject: NSObject] {
                    if let usersResult = locations["results"] as? [[String : AnyObject]] {
                        let studentsData = StudentInformation.convertFromDictionaries(usersResult)
                        completionHandler(result: studentsData, error: nil)
                    }
                }
            }
        }
    }
    
    // get user data from udacity
    func getUserPublicData(userId: String, completionHandler: (result: UserInformation?, error: NSError?) -> Void) {
        // method
        let method = Methods.Users + userId
        
        // mak the request
        _ = taskForGETMethod(RequestToServer.udacity, method: method, parameters: ["":""]) { (result, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            else {
                if let data = result["user"] as? NSDictionary {
                    let studentsInfo = UserInformation(dictionary: data)
                    completionHandler(result: studentsInfo, error: nil)
                }
            }
        }
    }
    
    // post user location to parse
    func sendUserLocation(userDetails: [String : AnyObject], completionHandler: (result: AnyObject?, error: NSError?) -> Void) {
        
        // make the request
        _ = taskForPOSTMethod(RequestToServer.parse, method: "", parameters: ["":""], jsonBody: userDetails, subdata: 0, completionHandler: { (result, error) -> Void in
            if error != nil {
                completionHandler(result: nil, error: error)
            } else {
                completionHandler(result: result, error: nil)
                
            }
        })
    }
    
    // set annotations for map with users data
    func createAnnotations(users: [StudentInformation], mapView: MKMapView) {
        for user in users {
            // set pin location
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = CLLocationCoordinate2DMake(user.latitude, user.longitude)
            annotation.title = "\(user.firstName) \(user.lastName)"
            annotation.subtitle = user.mediaURL
            
            mapView.addAnnotation(annotation)
        }
    }
    
    // logout request from udacity
    func logoutRequest(completionHandler: (result: AnyObject?, error: NSError?)->Void) {
        let request = NSMutableURLRequest(URL: NSURL(string: Constants.UdacityBaseURL + Methods.CreateSession)!)
        request.HTTPMethod = "DELETE"
        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in (sharedCookieStorage.cookies! as [NSHTTPCookie]) {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.addValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-Token")
        }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { data, response, error in
            if error != nil {
                completionHandler(result: nil, error: error)
            }
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            // println(NSString(data: newData, encoding: NSUTF8StringEncoding))
            completionHandler(result: newData, error: nil)
        }
        task.resume()
    }
    
    // logout user from udacity
    func logout(viewController: AnyObject) {
        UdacityClient.sharedInstance().logoutRequest { (result, error) -> Void in
            if error != nil {
                UdacityClient.sharedInstance().showAlert(error!, viewController: viewController)
            }
            else {
                dispatch_async(dispatch_get_main_queue(), {
                    let loginView : LoginViewController = viewController.storyboard?!.instantiateViewControllerWithIdentifier("LoginView") as! LoginViewController
                    viewController.presentViewController(loginView, animated: true, completion: nil)
                })
            }
        }
    }
}
