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

  fileprivate static let sharedInstance = PushNotificationController()

  // MARK: Internal

  static func registerApplicationForPushNotifications(_ application: UIApplication) {
    let notificationTypes: UIUserNotificationType = [.alert, .badge, .sound]
    let notificationSettings = UIUserNotificationSettings(types: notificationTypes, categories: nil)
    application.registerUserNotificationSettings(notificationSettings)
    application.registerForRemoteNotifications()
  }

  static func registrationCompletedWithDeviceToken(_ deviceToken: Data) {
    print("Push notification token: ", deviceToken.description)
    SnowballAPI.request(SnowballRoute.registerForPushNotifications(token: deviceToken.description)) { response in
      switch response {
      case .success: break
      case .failure(let error): print(error)
      }
    }
  }

  static func registrationFailedWithError(_ error: Error) {
    print("Push notification registration failed: ", error)
  }

  static func applicationDidReceiveRemoteNotificationWithUserInfo(_ userInfo: [AnyHashable: Any]) {
    if let aps = userInfo["aps"] as? [AnyHashable: Any], let message = aps["alert"] as? String {
      let alertController = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      alertController.addAction(UIAlertAction(title: NSLocalizedString("Ok", comment: ""), style: .cancel, handler: nil))
      AppDelegate.sharedInstance.window?.rootViewController?.present(alertController, animated: true, completion: nil)
    }
  }
}
