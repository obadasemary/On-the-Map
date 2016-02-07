//
//  PostViewController.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 2/4/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import UIKit
import MapKit

class PostViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var linkField: UITextField!
    @IBOutlet weak var findButton: UIButton!
    @IBOutlet weak var submitButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var mainText: UILabel!
    @IBOutlet weak var mapView: MKMapView!
    
    var latitude : CLLocationDegrees = CLLocationDegrees()
    var longitude : CLLocationDegrees = CLLocationDegrees()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        
        changeVisibility(true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "cancel")
        
        self.navigationItem.hidesBackButton = true
    }
    
    @IBAction func findOnMapAction(sender: UIButton) {
        
        if (!locationField.text!.isEmpty) {
            getGeocodLocation(locationField.text!)
            self.hideActivityIndicator()
        } else {
            locationField.becomeFirstResponder()
        }
    }
    
    @IBAction func submitAction(sender: UIButton) {
        
        if (!linkField.text!.isEmpty) {
            if (self.isValidURL(linkField.text!)) {
                showActivityIndicator()
                sendUserLocation()
            } else {
                let error = NSError(domain: "Invalid URL", code: 0, userInfo: ["NSLocalizedDescriptionKey" : "Invalid URL"])
                UdacityClient.sharedInstance().showAlert(error, viewController: self)
            }
        } else {
            linkField.becomeFirstResponder()
        }
    }
    
    func getGeocodLocation(address : String) {
        
        showActivityIndicator()
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) -> Void in
            
            if error != nil {
                UdacityClient.sharedInstance().showAlert(error!, viewController: self)
            } else {
                self.mapView.hidden = false
                self.submitButton.hidden = false
                self.linkField.hidden = false
                
                if let placemark = placemarks![0] as? CLPlacemark {
                    self.latitude = placemark.location!.coordinate.latitude
                    self.longitude = placemark.location!.coordinate.longitude
                    self.placeMarkerOnMap(placemark)
                }
                self.hideActivityIndicator()
                self.changeVisibility(false)
            }
        }
    }
    
    func placeMarkerOnMap(placemark: CLPlacemark) {
        
        let latDelta : CLLocationDegrees = 0.01
        let longDelta : CLLocationDegrees = 0.01
        
        let span : MKCoordinateSpan = MKCoordinateSpanMake(latDelta, longDelta)
        
        let loctaion : CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude, longitude)
        
        let region : MKCoordinateRegion = MKCoordinateRegionMake(loctaion, span)
        
        mapView.setRegion(region, animated: true)
        
        mapView.addAnnotation(MKPlacemark(placemark: placemark))
    }
    
    func showActivityIndicator() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
    }
    
    func hideActivityIndicator() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
    }
    
    func changeVisibility(firstStep: Bool) {
        findButton.hidden = !firstStep
        submitButton.hidden = firstStep
        locationField.hidden = !firstStep
        linkField.hidden = firstStep
        mapView.hidden = firstStep
        
        if (firstStep) {
            mainText.text = "Where are you studying today?"
        } else {
            mainText.text = "Enter associated link"
        }
    }
    
    func cancel() {
        self.navigationController?.popToRootViewControllerAnimated(true)
    }
    
    func isValidURL(urlString : String) -> Bool {
        let url = NSURL(string: urlString)!
        let requset = NSURLRequest(URL: url)
        return NSURLConnection.canHandleRequest(requset)
    }
    
    func sendUserLocation() {
        
        var userData : [String :AnyObject] = [String : AnyObject]()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        
        UdacityClient.sharedInstance().getUserPublicData(appDelegate.studentKey) { (userInformation, error) -> Void in
            
            if userInformation != nil {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    userData = [
                        UdacityClient.JSONBodyKeys.UniqueKey : appDelegate.studentKey,
                        UdacityClient.JSONBodyKeys.FirstName : userInformation!.firstName,
                        UdacityClient.JSONBodyKeys.LastName : userInformation!.lastName,
                        UdacityClient.JSONBodyKeys.MapString : self.locationField.text!,
                        UdacityClient.JSONBodyKeys.MediaURL : self.linkField.text!,
                        UdacityClient.JSONBodyKeys.Latitude : self.latitude,
                        UdacityClient.JSONBodyKeys.Longitude : self.longitude
                    ]
                    
                    UdacityClient.sharedInstance().sendUserLocation(userData, completionHandler: { (result, error) -> Void in
                        
                        if error != nil {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.hideActivityIndicator()
                                UdacityClient.sharedInstance().showAlert(error!, viewController: self)

                            })
                        } else {
                            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                                self.hideActivityIndicator()
                                self.cancel()
                            })
                        }
                    })
                })
            } else {
                if error != nil {
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                    })
                }
            }
        }
    }
}
