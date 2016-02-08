//
//  MapViewController.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 1/26/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add pin button
        let pinButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain, target: self, action: "addPinAction")
        
        // add refresh button
        let refreshButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadAction")
        
        
        // add the buttons
        self.navigationItem.rightBarButtonItems = [refreshButton, pinButton]
        
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Done, target: self, action: "logout")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.reloadUsersData()
    }
    
    func addPinAction() {
        let postController:UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("postView")
        //self.presentViewController(postController, animated: true, completion: nil)
        self.navigationController?.pushViewController(postController, animated: true)
    }
    
    func reloadAction() {
        self.reloadUsersData()
    }
    
    //reload users data
    func reloadUsersData() {
        
        UdacityClient.sharedInstance().getStudentLocations { users, error in
            if let usersData =  users {
                dispatch_async(dispatch_get_main_queue(), {
//                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                    appDelegate.usersData = usersData
                    StudentData.usersData = usersData
                    UdacityClient.sharedInstance().createAnnotations(usersData, mapView: self.mapView)
                })
            } else {
                if error != nil {
                    UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                }
            }
        }
    }
    
    // setup pin properties
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKPointAnnotation {
            let pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "myPin")
            pinView.pinColor = .Red
            pinView.canShowCallout = true
            
            // pin button
            let pinButton = UIButton(type: UIButtonType.InfoLight)
            pinButton.frame.size.width = 44
            pinButton.frame.size.height = 44
            
            pinView.rightCalloutAccessoryView = pinButton
            
            return pinView
        }
        return nil
    }
    
    // click to pin
    func mapView(mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        // open url
        UdacityClient.sharedInstance().openURL(view.annotation!.subtitle!!)
    }
    
    func logout() {
        UdacityClient.sharedInstance().logout(self)
    }
}
