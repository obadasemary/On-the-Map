//
//  MapViewController.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 1/26/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: BaseViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let locations = hardCodedLocationData()
        
        var annotations = [MKPointAnnotation]()
        
        for dic in locations {
            
            let lat = CLLocationDegrees(dic["latitude"] as! Double)
            let long = CLLocationDegrees(dic["longitude"] as! Double)
            
            let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
            
            let first = dic["firstName"] as! String
            let last = dic["lastName"] as! String
            let mediaURL = dic["mediaURL"] as! String
            
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = "\(first) \(last)"
            annotation.subtitle = mediaURL
            
            annotations.append(annotation)
        }
        self.mapView.addAnnotations(annotations)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = UIColor(red: 1, green: 0, blue: 0, alpha: 1)
            pinView!.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    func mapView(mapView: MKMapView, annotationView: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        if control == annotationView.rightCalloutAccessoryView {
            let app = UIApplication.sharedApplication()
            app.openURL(NSURL(string: annotationView.annotation!.subtitle!!)!)
        }
    }
    
    func hardCodedLocationData() -> [[String : AnyObject]] {
        return [
            [
                "createdAt" : "2016-01-24T22:27:14.456Z",
                "firstName" : "Abdelrahman",
                "lastName" : "Mohamed",
                "latitude" : 25.285646,
                "longitude" : 51.535406,
                "mapString" : "Doha, Qatar",
                "mediaURL" : "https://qa.linkedin.com/in/obadasemary",
                "objectId" : "kj18GEaWD8",
                "uniqueKey" : 872458750,
                "updatedAt" : "2016-01-25T22:07:09.593Z"
            ],
            [
                "createdAt" : "2016-01-25T22:27:14.456Z",
                "firstName" : "Sara",
                "lastName" : "Seif",
                "latitude" : 30.630760,
                "longitude" : 31.938534,
                "mapString" : "Cairo, Egypt",
                "mediaURL" : "https://qa.linkedin.com/in/saraseif",
                "objectId" : "kj18GEaWD8",
                "uniqueKey" : 872458750,
                "updatedAt" : "2016-01-26T22:07:09.593Z"
            ]
        ]
    }
    
    @IBAction func didPressLogout(sender: UIBarButtonItem) {
        
        sender.enabled = false
        User.logOut { (success) -> Void in
            sender.enabled = true
            if !success {
                self.showErrorAlert("Logout Failed", defaultMessage: "Could not log out", errors: User.errors)
            } else {
                self.dismissViewControllerAnimated(true, completion: nil)
            }
        }
        
    }
    
}
