//
//  UdacityClient.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 2/2/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - GET
    
    func taskForGETMethod(server: String, method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Set the parameters */
        let mutableParameters = parameters
        
        /* Set server base url */
        var baseUrl : String = ""
        if (server == RequestToServer.udacity) {
            baseUrl = Constants.UdacityBaseURL
        } else if (server == RequestToServer.parse) {
            baseUrl = Constants.ParseBaseURL
        }
        
        /* Build the URL and configure the request */
        let urlString = baseUrl + method + UdacityClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        if (server == RequestToServer.parse) {
            request.addValue(Constants.parseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.parseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        }
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* Parse the data and use the data (happens in completion handler) */
            if downloadError != nil {
                completionHandler(result: nil, error: downloadError)
            } else {
                var newData: NSData?
                newData = nil
                if (server == RequestToServer.udacity) {
                    newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5))
                }
                if newData != nil {
                    UdacityClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
                }
                else {
                    UdacityClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: - POST
    
    func taskForPOSTMethod(server: String, method: String, parameters: [String : AnyObject], jsonBody: [String:AnyObject], subdata: Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        /* Set the parameters */
        let mutableParameters = parameters
        
        /* Set server base url */
        var baseUrl : String = ""
        if (server == RequestToServer.udacity) {
            baseUrl = Constants.UdacityBaseURL
        } else if (server == RequestToServer.parse) {
            baseUrl = Constants.ParseBaseURL
        }
        
        /* Build the URL and configure the request */
        let urlString = baseUrl + method + UdacityClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        var jsonifyError: NSError? = nil
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonBody, options: [])
        } catch let error as NSError {
            jsonifyError = error
            request.HTTPBody = nil
        }
        
        if (server == RequestToServer.parse) {
            request.addValue(Constants.parseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.parseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        /* Make the request */
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            /* Parse the data and use the data (happens in completion handler) */
            if downloadError != nil {
                completionHandler(result: nil, error: downloadError)
            } else {
                var newData: NSData?
                newData = nil
                if subdata > 0 {
                    newData = data!.subdataWithRange(NSMakeRange(subdata, data!.length - subdata))
                }
                if newData != nil {
                    UdacityClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
                }
                else {
                    UdacityClient.parseJSONWithCompletionHandler(data!, completionHandler: completionHandler)
                }
            }
        }
        
        /* Start the request */
        task.resume()
        
        return task
    }
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        var parsingError: NSError? = nil
        
        let parsedResult: AnyObject?
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
        } catch let error as NSError {
            parsingError = error
            parsedResult = nil
        }
        
        if let error = parsingError {
            completionHandler(result: nil, error: error)
        } else {
            completionHandler(result: parsedResult, error: nil)
        }
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            if(!key.isEmpty) {
                /* Make sure that it is a string value */
                let stringValue = "\(value)"
                
                /* Escape it */
                let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
                
                /* Append it */
                urlVars += [key + "=" + "\(escapedValue!)"]
            }
            
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    // MARK: - Show error alert
    func showAlert(message: NSError, viewController: AnyObject) {
        let errMessage = message.localizedDescription
        
        let alert = UIAlertController(title: nil, message: errMessage, preferredStyle: UIAlertControllerStyle.Alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default, handler: { action in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    func openURL(urlString: String) {
        let url = NSURL(string: urlString)
        UIApplication.sharedApplication().openURL(url!)
    }
    
    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityClient {
        
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        
        return Singleton.sharedInstance
    }
}
