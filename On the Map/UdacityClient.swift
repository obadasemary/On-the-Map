//
//  UdacityClient.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 2/2/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import Foundation
import UIKit

class UdacityClient: NSObject {
    
    /* Shared session */
    var session : NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    // MARK: - GET
    func taskForGETMethod(server: String, method: String, parameters: [String : AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void ) -> NSURLSessionDataTask {

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
        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) -> Void in
            
            guard (downloadError != nil) else {
                completionHandler(result: nil, error: downloadError)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                print("No data was returned by the requset!")
                return
            }
            
            var newData : NSData?
            newData = nil
            
            if (server == RequestToServer.udacity) {
                newData = data.subdataWithRange(NSMakeRange(5, data.length - 5))
            }
            
            if newData != nil {
                UdacityClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
            } else {
                UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        return task
    }
    
    func taskForPOSTMethod(server: String, method: String, parameters: [String : AnyObject], jsonbody: [String : AnyObject], subdata: Int, completionHandler: (result: AnyObject!, error: NSError?) -> Void ) -> NSURLSessionDataTask {
        
        let mutableParameters = parameters
        
        var baseUrl = ""
        if (server == RequestToServer.udacity) {
            baseUrl = Constants.UdacityBaseURL
        } else if (server == RequestToServer.parse) {
            baseUrl = Constants.ParseBaseURL
        }
        
        /* Build the URL and configure the request */
        let urlString = baseUrl + method + UdacityClient.escapedParameters(mutableParameters)
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            request.HTTPBody = try NSJSONSerialization.dataWithJSONObject(jsonbody, options: [])
        } catch {
            request.HTTPBody = nil
        }
        
        if (server == RequestToServer.parse) {
            request.addValue(Constants.parseAppId, forHTTPHeaderField: "X-Parse-Application-Id")
            request.addValue(Constants.parseApiKey, forHTTPHeaderField: "X-Parse-REST-API-Key")
        } else {
            request.addValue("application/json", forHTTPHeaderField: "Accept")
        }
        
        let task = session.dataTaskWithRequest(request) { (data, response, downloadError) -> Void in
            
            guard (downloadError != nil) else {
                completionHandler(result: nil, error: downloadError)
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                if let response = response as? NSHTTPURLResponse {
                    print("Your request returned an invalid response! Status code: \(response.statusCode)!")
                } else if let response = response {
                    print("Your request returned an invalid response! Response: \(response)!")
                } else {
                    print("Your request returned an invalid response!")
                }
                return
            }
            
            guard let data = data else {
                print("No data was returned by the requset!")
                return
            }
            
            var newData : NSData?
            newData = nil
            
            if subdata > 0 {
                newData = data.subdataWithRange(NSMakeRange(subdata, data.length - subdata))
            }
            
            if newData != nil {
                UdacityClient.parseJSONWithCompletionHandler(newData!, completionHandler: completionHandler)
            } else {
                UdacityClient.parseJSONWithCompletionHandler(data, completionHandler: completionHandler)
            }
        }
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
    
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) ->  Void ) {
        
        var parsingError: NSError? = nil

        let parsedResult: AnyObject!
        do {
            parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments)
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
            if (!key.isEmpty) {
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
        let errorMessage = message.localizedDescription
        
        let alert = UIAlertController(title: nil, message: errorMessage, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { (action) -> Void in
            alert.dismissViewControllerAnimated(true, completion: nil)
        }))
        
        viewController.presentViewController(alert, animated: true, completion: nil)
    }
    
    // MARK: - Open URL
    func opernURL(urlString: String) {
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