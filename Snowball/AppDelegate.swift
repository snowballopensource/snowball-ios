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
    UINavigationBar.appearance().barTintColor = UIColor.whiteColor()
    // new navigation bar height: 64; old navigation bar height: 44
    // 64-44 = 20; 20/2 = 10
    // yay math!
    let verticalPositionOffset = -10.0 as CGFloat
    UINavigationBar.appearance().setTitleVerticalPositionAdjustment(verticalPositionOffset, forBarMetrics: UIBarMetrics.Default)
    UINavigationBar.appearance().titleTextAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(20.0),
      NSForegroundColorAttributeName: UIColor.blackColor()
    ]
    UIBarButtonItem.appearance().setBackButtonTitlePositionAdjustment(UIOffsetMake(-1000.0, 0), forBarMetrics: UIBarMetrics.Default)
    // Blank back indicator since our image takes care of it
    UINavigationBar.appearance().backIndicatorImage = UIImage()
    UINavigationBar.appearance().backIndicatorTransitionMaskImage = UIImage()
    // Our image goes here!
    var backImage = UIImage(named: "back-normal")
    // Use the width for the cap resets so it doesn't do the auto resize.
    backImage = backImage!.resizableImageWithCapInsets(UIEdgeInsetsMake(0, backImage!.size.width, 0, 0))
    UIBarButtonItem.appearance().setBackButtonBackgroundVerticalPositionAdjustment(verticalPositionOffset, forBarMetrics: UIBarMetrics.Default)
    UIBarButtonItem.appearance().setBackButtonBackgroundImage(backImage, forState: UIControlState.Normal, barMetrics: UIBarMetrics.Default)

    // Bridged Appearance
    // Solves the lack of appearanceWhenContainedIn in Swift
    // http://stackoverflow.com/q/24136874/801858
    AppearanceBridger.setAppearance()
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