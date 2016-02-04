//
//  LoginViewController.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 1/27/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import UIKit

class LoginViewController: BaseViewController, UITextFieldDelegate {


    @IBOutlet weak var usernameTextField: LoginTextField!
    @IBOutlet weak var passwordTextField: LoginTextField!
    @IBOutlet weak var loginLabel: UILabel!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.setTitle("Logging in ... , Please wait.", forState: .Disabled)
        loginButton.setTitle("Log in", forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeToKeyboardNotifications()
        loginButton.layoutSubviews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeFromKeyboardNotifications()
    }
    
    @IBAction func loginButtonTouch(sender: UIButton) {
        
        setFormState(true)
        self.showActivityIndicator()
        
        //hide keyboard
        self.view.endEditing(true)
        
        //request to login user
        UdacityClient.sharedInstance().userLogin(usernameTextField.text!, password: passwordTextField.text!) { (result, error) -> Void in
            
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), {
                    UdacityClient.sharedInstance().showAlert(error!, viewController: self)
                    self.hideActivityIndicator()
                })
            }
            else {
                // show map tab view
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.studentKey = result!
                dispatch_async(dispatch_get_main_queue(), {
                    self.hideActivityIndicator()
                    self.setFormState(false)
                    self.performSegueWithIdentifier("showTabs", sender: self)
                })
            }
        }
    }
    
    @IBAction func signUpButtonTouch(sender: UIButton) {
        // set url
        let signUpURL = "https://www.udacity.com/account/auth#!/signup"
        // open url in browser
        UIApplication.sharedApplication().openURL(NSURL(string: signUpURL)!)
    }
    
    func showActivityIndicator() {
        activityIndicator.hidden = false
        activityIndicator.startAnimating()
        loginButton.hidden = true
    }
    
    func hideActivityIndicator() {
        activityIndicator.hidden = true
        activityIndicator.stopAnimating()
        loginButton.hidden = false
    }
    
    private func setFormState(loggingIn: Bool, errorMessage: String? = nil) {
        usernameTextField.enabled = !loggingIn
        passwordTextField.enabled = !loggingIn
        loginButton.enabled = !loggingIn
        if let message = errorMessage {
            showErrorAlert("Authentication Error", defaultMessage: message, errors: [])
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
    
    // MARK: - Keyboard methods
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        self.view.frame.origin.y = -getKeyboardHeight(notification)
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    func keyboardWillHide(notification: NSNotification) {
        self.view.frame.origin.y = 0
    }

}
