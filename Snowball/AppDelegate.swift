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

  // MARK: - UIApplicationDelegate

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    setupWindow()
    return true
  }

  // MARK: - Public

  class func getReference() -> AppDelegate {
    return UIApplication.sharedApplication().delegate! as AppDelegate
  }

  class func switchToNavigationController(navigationController: UINavigationController) {
    if let window = getReference().window {
      UIView.transitionWithView(window, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () in
        let oldState = UIView.areAnimationsEnabled()
        UIView.setAnimationsEnabled(false)
        window.rootViewController = navigationController
        UIView.setAnimationsEnabled(oldState)
        }, completion: nil)
    }
  }

  // MARK: - Private

  private class var initialViewController: UIViewController {
    if User.currentUser == nil { return OnboardingNavigationController() }
    return MainNavigationController()
  }

  private func setupWindow() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window?.backgroundColor = UIColor.whiteColor()
    window?.rootViewController = AppDelegate.initialViewController
    window?.makeKeyAndVisible()
  }
}

