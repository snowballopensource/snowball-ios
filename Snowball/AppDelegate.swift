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
    return UIApplication.sharedApplication().delegate as! AppDelegate
  }

  var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.backgroundColor = UIColor.whiteColor()
    window.rootViewController = HomeNavigationController()
    return window
  }()
}

// MARK: - UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate {
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
//    print("Realm Path: " + Database.realm.path)
    Clip.cleanUpFailedClipUploads()
    PushNotificationController.registerApplicationForPushNotifications(application)
    Analytics.initialize()
    window?.makeKeyAndVisible()
    return true
  }

  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    PushNotificationController.registrationCompletedWithDeviceToken(deviceToken)
  }

  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    PushNotificationController.registrationFailedWithError(error)
  }

  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject: AnyObject]) {
    PushNotificationController.applicationDidReceiveRemoteNotificationWithUserInfo(userInfo)
  }
}
