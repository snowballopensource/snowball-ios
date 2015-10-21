//
//  NSError+Display.swift
//  Snowball
//
//  Created by James Martinez on 10/21/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import UIKit

extension NSError {
  func alertUser() {
    let title = NSLocalizedString("Error", comment: "")
    var message = localizedFailureReason
    if message == nil { message = NSLocalizedString("An unknown error has occured.", comment: "") }
    let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alert.display()
  }
}