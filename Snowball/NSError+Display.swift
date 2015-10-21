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
    var message = localizedFailureReason
    if message == nil { message = NSLocalizedString("An unknown error has occured.", comment: "") }
    UIAlertController.displayAlertWithTitle(NSLocalizedString("Error", comment: ""), message: message)
  }
}