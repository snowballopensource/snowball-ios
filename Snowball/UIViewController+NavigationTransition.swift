//
//  UIViewController+NavigationTransition.swift
//  Snowball
//
//  Created by James Martinez on 2/25/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIViewController {

  func switchToNavigationController(navigationController: UINavigationController) {
    let window = AppDelegate.sharedDelegate.window
    UIView.transitionWithView(window, duration: 0.5, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: {
      let oldState = UIView.areAnimationsEnabled()
      UIView.setAnimationsEnabled(false)
      window.rootViewController = navigationController
      UIView.setAnimationsEnabled(oldState)
      }, completion: nil)
  }

}