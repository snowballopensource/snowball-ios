//
//  UIAlertController+Display.swift
//  Snowball
//
//  Created by James Martinez on 10/21/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIAlertController {
  func display() {
    if let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController {
      rootVC.presentViewController(self, animated: true, completion: nil)
    }
  }
}