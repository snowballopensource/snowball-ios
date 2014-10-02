//
//  NSError+.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

extension NSError {
  // Since class variables are not yet supported...
  class func kSnowballAPIErrorMessage() -> String {
    return "SnowballAPIErrorMessage"
  }

  func display() {
    var message = NSLocalizedString("Something went wrong. Please try again!")
    if let userInfo = userInfo {
      if let snowballAPIErrorMessage = userInfo[NSError.kSnowballAPIErrorMessage()] as AnyObject? as? String {
        message = snowballAPIErrorMessage
      }
    }
    let rootViewController = UIApplication.sharedApplication().delegate!.window!!.rootViewController
    let alertController = UIAlertController(title: NSLocalizedString("Oops!"), message: message, preferredStyle: UIAlertControllerStyle.Alert)
    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK"), style: UIAlertActionStyle.Cancel, handler: nil))
    rootViewController?.presentViewController(alertController, animated: true) {}
  }
}