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
    let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
    if let rootVC = AppDelegate.sharedDelegate.window!.rootViewController {
      rootVC.presentViewController(alertController, animated: true, completion: nil)
    }
  }
}