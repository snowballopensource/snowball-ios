//
//  AppDelegate.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow? = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.rootViewController = ViewController()
    return window
  }()

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window?.makeKeyAndVisible()
    return true
  }
}

