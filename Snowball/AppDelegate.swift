//
//  AppDelegate.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Crashlytics
import Fabric
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder {

  // MARK: - Properties

  class var sharedDelegate: AppDelegate {
    return UIApplication.sharedApplication().delegate! as! AppDelegate
  }

  lazy var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.backgroundColor = UIColor.whiteColor()
    window.rootViewController = initialViewController
    return window
    }()

  private class var initialViewController: UIViewController {
    if User.currentUser == nil { return AuthenticationNavigationController() }
    return MainNavigationController()
  }
}

// MARK: - UIApplicationDelegate
extension AppDelegate: UIApplicationDelegate {
  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window?.makeKeyAndVisible()
    Fabric.with([Crashlytics()])
    application.applicationSupportsShakeToEdit = true
    Clip.cleanupUploadingStates()
    return true
  }
  
  func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
    PushManager.registrationSucceeded(deviceToken: deviceToken)
  }
  
  func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
    PushManager.registrationFailed(error: error)
  }
  
  func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
    PushManager.handleRemoteNotification(userInfo: userInfo)
  }
}
