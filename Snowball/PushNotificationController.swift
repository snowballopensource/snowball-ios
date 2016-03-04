//
//  PushNotificationController.swift
//  Snowball
//
//  Created by James Martinez on 3/3/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

class PushNotificationController {

  // MARK: Properties

  private static let sharedInstance = PushNotificationController()

  // MARK: Internal

  static func registerApplicationForPushNotifications(application: UIApplication) {
    let notificationTypes: UIUserNotificationType = [.Alert, .Badge, .Sound]
    let notificationSettings = UIUserNotificationSettings(forTypes: notificationTypes, categories: nil)
    application.registerUserNotificationSettings(notificationSettings)
    application.registerForRemoteNotifications()
  }

  static func registrationCompletedWithDeviceToken(deviceToken: NSData) {
    print("Push notification token: ", deviceToken.description)
    SnowballAPI.request(SnowballRoute.RegisterForPushNotifications(token: deviceToken.description)) { response in
      switch response {
      case .Success: break
      case .Failure(let error): print(error)
      }
    }
  }

  static func registrationFailedWithError(error: NSError) {
    // TODO: Show error
    print("Push notification registration failed: ", error)
  }

  static func applicationDidReceiveRemoteNotificationWithUserInfo(userInfo: [NSObject: AnyObject]) {
    // TODO: Show alert
    print("Push notification received while application in use: ", userInfo)
  }
}