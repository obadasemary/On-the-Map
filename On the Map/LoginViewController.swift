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
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        loginButton.setTitle("Logging in ... , Please wait.", forState: .Disabled)
        loginButton.setTitle("Log in", forState: .Normal)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        loginButton.layoutSubviews()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    @IBAction func loginButtonTouch(sender: UIButton) {
        
        setFormState(true)
        if let username = usernameTextField.text, password = passwordTextField.text {
            User.logIn(username, password: password, didComplete: { (success, errorMessage) -> Void in
                self.setFormState(false, errorMessage: errorMessage)
                if success {
                    self.setFormState(false)
                    print("Success Login")
                    self.performSegueWithIdentifier("showTabs", sender: self)
                }
            })
        }
    }
    
    private func setFormState(loggingIn: Bool, errorMessage: String? = nil) {
        
        usernameTextField.enabled = !loggingIn
        passwordTextField.enabled = !loggingIn
        loginButton.enabled = !loggingIn
        if let message = errorMessage {
            showErrorAlert("Authentication Error", defaultMessage: message, errors: [])
        }
    }
    
//    func showErrorAlert(title: String, defaultMessage: String, errors: [NSError]) {
//        var message = defaultMessage
//        if !errors.isEmpty {
//            message = errors[0].localizedDescription
//        }
//        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
//        let OkAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
//        alertController.addAction(OkAction)
//        self.presentViewController(alertController, animated: true, completion: nil)
//    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if textField == usernameTextField {
            passwordTextField.becomeFirstResponder()
        } else {
            textField.resignFirstResponder()
        }
        return true
    }
}
