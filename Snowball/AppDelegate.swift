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
    if User.currentUser == nil {
      let navigationController = UINavigationController(rootViewController: OnboardingViewController())
      navigationController.navigationBarHidden = true
      return navigationController
    }
    return HomeViewController()
  }

  private func setupWindow() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.backgroundColor = UIColor.whiteColor()
    window?.rootViewController = AppDelegate.initialViewController
    window?.makeKeyAndVisible()
  }

  // MARK: - UIApplicationDelegate

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    setupWindow()
    return true
  }
}

