//
//  UIWindow+RootViewControllerTransition.swift
//  Snowball
//
//  Created by James Martinez on 1/28/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIWindow {
  func transitionRootViewControllerToViewController(viewController: UIViewController) {
    UIView.transitionWithView(self, duration: 0.5, options: .TransitionFlipFromLeft, animations: {
      self.rootViewController = viewController
      }, completion: nil)
  }
}