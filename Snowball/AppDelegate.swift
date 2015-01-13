//
//  AppDelegate.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  // MARK: - Private

  private class var initialViewController: UIViewController {
    return OnboardingViewController()
  }

  // This is not a property since UIScreen.mainScreen().bounds is not set
  // until application(_:didFinishLaunchingWithOptions:) is called.
  private func setWindow() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window!.backgroundColor = UIColor.whiteColor()
    window!.rootViewController = AppDelegate.initialViewController
    window!.makeKeyAndVisible()
  }

  // MARK: - UIApplicationDelegate

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    setWindow()
    return true
  }
}

