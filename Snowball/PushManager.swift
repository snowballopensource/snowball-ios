//
//  PushManager.swift
//  Snowball
//
//  Created by James Martinez on 5/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Parse
import UIKit

struct PushManager {

  // MARK: - Internal

  static func registerForPushNotifications() {
    Parse.setApplicationId("XfkcX3ZtlbyMxbSgeblGLixNuJCkmdCVEFBDkf6J",
      clientKey: "BW8JgNZNUvWG6lvcfQUGscEKkqtJUpTRRkhw13ze")

    let types: UIUserNotificationType = [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound]
    let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
    let application = UIApplication.sharedApplication()
    application.registerUserNotificationSettings(settings)
    application.registerForRemoteNotifications()
  }

  static func registrationSucceeded(deviceToken deviceToken: NSData) {
    let installation = PFInstallation.currentInstallation()
    installation.setDeviceTokenFromData(deviceToken)
    associateCurrentInstallationWithCurrentUser()
    installation.saveInBackgroundWithBlock(nil)
  }

  static func registrationFailed(error error: NSError) {
    print("Push notification registration failed.")
  }

  static func handleRemoteNotification(userInfo userInfo: [NSObject: AnyObject]) {
    print("Push notification received: \(userInfo)")

    let applicationState = UIApplication.sharedApplication().applicationState
    if applicationState == UIApplicationState.Active {
      if let aps = userInfo["aps"] as? [String: AnyObject] {
        if let message = aps["alert"] as? String {
          let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
          let okAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Default, handler: nil)
          alert.addAction(okAction)
          if let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController {
            rootVC.presentViewController(alert, animated: true, completion: nil)
          }
        }
      }
    }
  }

  static func associateCurrentInstallationWithCurrentUser(saveImmediately saveImmediately: Bool = false) {
    if let userID = User.currentUser?.id {
      let installation = PFInstallation.currentInstallation()
      let installationUserID = installation["user_id"] as? String
      if installationUserID != userID {
        installation["user_id"] = userID
        if saveImmediately {
          installation.saveInBackgroundWithBlock(nil)
        }
      }
    }
  }
}