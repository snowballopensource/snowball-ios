//
//  UIViewController+Shake.swift
//  Snowball
//
//  Created by James Martinez on 7/8/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import CoreData
import UIKit

extension UIViewController {
  override public func motionEnded(motion: UIEventSubtype, withEvent event: UIEvent?) {
    if motion == UIEventSubtype.MotionShake {
//      let alertController = UIAlertController(title: NSLocalizedString("Shaking it up!", comment: ""), message: "New color scheme, coming right up!", preferredStyle: UIAlertControllerStyle.Alert)
//      alertController.addAction(UIAlertAction(title: NSLocalizedString("Cool!", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
//
//      if let rootVC = AppDelegate.sharedDelegate.window!.rootViewController {
//        rootVC.presentViewController(alertController, animated: true) {
//          let users = User.findAll() as! [User]
//          for user in users {
//            user.color = UIColor.SnowballColor.randomColor
//          }
//          if let context = users.first!.managedObjectContext {
//            context.save(nil)
//          }
//        }
//      }
    }
  }
}