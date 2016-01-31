//
//  BaseViewController.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 1/31/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import UIKit
import MapKit

class BaseViewController: UIViewController {

    internal func showErrorAlert(title: String, defaultMessage: String, errors: [NSError]) {
        var message = defaultMessage
        if !errors.isEmpty {
            message = errors[0].localizedDescription
        }
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        let OkAction = UIAlertAction(title: "OK", style: .Default) { (action) in }
        alertController.addAction(OkAction)
        self.presentViewController(alertController, animated: true, completion: nil)
    }
}
