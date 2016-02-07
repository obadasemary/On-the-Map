//
//  ListViewController.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 2/4/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {

    @IBOutlet weak var mainTable: UITableView!

    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pinButton : UIBarButtonItem = UIBarButtonItem(image: UIImage(named: "pin"), landscapeImagePhone: nil, style: UIBarButtonItemStyle.Plain, target: self, action: "addPinAction")
        
        let refreshButton : UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Refresh, target: self, action: "reloadAction")
        
        
        // add the buttons
        self.navigationItem.rightBarButtonItems = [refreshButton, pinButton]
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: UIBarButtonItemStyle.Done, target: self, action: "logout")
    }
    
    override func viewWillAppear(animated: Bool) {
        self.reloadUsersData()
    }
    
    //action - add location for current user
    func addPinAction() {
        let postController:UIViewController = self.storyboard!.instantiateViewControllerWithIdentifier("postView")
        self.presentViewController(postController, animated: true, completion: nil)
    }
    
    //action - reload users location
    func reloadAction() {
        self.reloadUsersData()
    }
    
    func logout() {
        UdacityClient.sharedInstance().logout(self)
    }

    func reloadUsersData() {
        _ = [StudentInformation]()
        UdacityClient.sharedInstance().getStudentLocations { users, error in
            if let usersData =  users {
                dispatch_async(dispatch_get_main_queue(), {
//                    let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
//                    appDelegate.usersData = usersData
                    StudentInformation.usersData = usersData
                    self.mainTable.reloadData()
                })
            } else {
                if error != nil {
                    UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                }
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("UserData", forIndexPath: indexPath)
        
//        let firstName = appDelegate.usersData[indexPath.row].firstName
        let firstName = StudentInformation.usersData[indexPath.row].firstName
//        let lastName = appDelegate.usersData[indexPath.row].lastName
        let lastName = StudentInformation.usersData[indexPath.row].lastName
        
        cell.textLabel?.text = "\(firstName) \(lastName)"
        cell.imageView?.image = UIImage(named: "pin")
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
//        UdacityClient.sharedInstance().openURL(appDelegate.usersData[indexPath.row].mediaURL)
        UdacityClient.sharedInstance().openURL(StudentInformation.usersData[indexPath.row].mediaURL)
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return appDelegate.usersData.count
        return StudentInformation.usersData.count
    }

}
