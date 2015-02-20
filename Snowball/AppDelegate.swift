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
class AppDelegate: UIResponder, UIApplicationDelegate {

  // MARK: - Properties

  lazy var window: UIWindow = {
    let window = UIWindow(frame: UIScreen.mainScreen().bounds)
    window.backgroundColor = UIColor.whiteColor()
    window.rootViewController = initialViewController
    return window
    }()

  private class var initialViewController: UIViewController {
    if User.currentUser == nil { return AuthenticationNavigationController() }
    return MainNavigationController()
  }

  // MARK: - UIApplicationDelegate

  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    window.makeKeyAndVisible()
    Fabric.with([Crashlytics()])
    return true
  }

  // MARK: - Internal

  class func getReference() -> AppDelegate {
    return UIApplication.sharedApplication().delegate! as AppDelegate
  }

  class func switchToNavigationController(navigationController: UINavigationController) {
    let window = getReference().window
    UIView.transitionWithView(window, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () in
      let oldState = UIView.areAnimationsEnabled()
      UIView.setAnimationsEnabled(false)
      window.rootViewController = navigationController
      UIView.setAnimationsEnabled(oldState)
      }, completion: nil)
  }
}

