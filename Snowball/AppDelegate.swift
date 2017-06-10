//
//  AppDelegate.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {

  // MARK: Properties

  static var sharedInstance: AppDelegate {
    return UIApplication.shared.delegate as! AppDelegate
  }

  var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.main.bounds)
    window.backgroundColor = UIColor.white
    window.rootViewController = HomeNavigationController()
    return window
  }()
}

// MARK: - UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate {
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
//    print("Realm Path: " + Database.realm.path)
    Clip.cleanUpFailedClipUploads()
    PushNotificationController.registerApplicationForPushNotifications(application)
    Analytics.initialize()
    window?.makeKeyAndVisible()
    return true
  }

  func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
    PushNotificationController.registrationCompletedWithDeviceToken(deviceToken)
  }

  func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
    PushNotificationController.registrationFailedWithError(error)
  }

  func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
    PushNotificationController.applicationDidReceiveRemoteNotificationWithUserInfo(userInfo)
  }
}
