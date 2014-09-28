//
//  Util.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

typealias CompletionHandler = (NSError?) -> ()

func NSLocalizedString(key: String) -> String {
  return NSLocalizedString(key, comment: "")
}

func requireSubclass() {
  fatalError("This method should be overridden by a subclass.")
}

func switchToNavigationController(navigationController: UINavigationController) {
  UIView.transitionWithView(UIApplication.sharedApplication().delegate!.window!!, duration: 0.8, options: UIViewAnimationOptions.TransitionFlipFromLeft, animations: { () in
    let oldState = UIView.areAnimationsEnabled()
    UIView.setAnimationsEnabled(false)
    UIApplication.sharedApplication().delegate!.window!!.rootViewController = navigationController
    UIView.setAnimationsEnabled(oldState)
  }, completion: nil)
}