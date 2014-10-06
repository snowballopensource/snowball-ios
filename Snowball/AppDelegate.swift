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