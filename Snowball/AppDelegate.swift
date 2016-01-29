//
//  AppDelegate.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Haneke
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
    window?.makeKeyAndVisible()
    Shared.dataCache.removeAll()
    return true
  }
}
