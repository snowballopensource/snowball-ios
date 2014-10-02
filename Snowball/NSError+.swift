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
  func display() {
    let rootViewController = UIApplication.sharedApplication().delegate!.window!!.rootViewController
    let alertController = UIAlertController(title: NSLocalizedString("Error"), message: localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK"), style: UIAlertActionStyle.Cancel, handler: nil))
    rootViewController?.presentViewController(alertController, animated: true) {}
  }
}