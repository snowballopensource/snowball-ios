//
//  AppDelegate.swift
//  Snowball
//
//  Created by James Martinez on 9/17/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func initialViewController() -> UIViewController {
    if let authToken = APICredential.authToken {
      return MainNavigationController()
    } else {
      return AuthenticationNavigationController()
    }
  }

  private func setAppearance() {
    // UINavigationBar
    // http://stackoverflow.com/a/18969325/801858
    UINavigationBar.appearance().setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
    UINavigationBar.appearance().shadowImage = UIImage()
    UINavigationBar.appearance().translucent = false
    UINavigationBar.appearance().barTintColor = UIColor.SnowballColor.blue()
    // new navigation bar height: 64; old navigation bar height: 44
    // 64-44 = 20; 20/2 = 10
    // yay math!
    UINavigationBar.appearance().setTitleVerticalPositionAdjustment(-10.0, forBarMetrics: UIBarMetrics.Default)
    UINavigationBar.appearance().titleTextAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(20.0),
      NSForegroundColorAttributeName: UIColor.whiteColor()
    ]
  }

  // MARK: UIApplicationDelegate

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.rootViewController = initialViewController()
    window?.makeKeyAndVisible()
    setAppearance()
    return true
  }

}