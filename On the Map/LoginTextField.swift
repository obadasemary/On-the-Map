//
//  LoginTextField.swift
//  On the Map
//
//  Created by Abdelrahman Mohamed on 1/31/16.
//  Copyright © 2016 Abdelrahman Mohamed. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class LoginTextField: UITextField {
    
    @IBInspectable var xInset: CGFloat = 10
    @IBInspectable var yInset: CGFloat = 5
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds, xInset, yInset)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
}
