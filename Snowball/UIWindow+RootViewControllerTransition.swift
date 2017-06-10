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
  func transitionRootViewControllerToViewController(_ viewController: UIViewController) {
    UIView.transition(with: self, duration: 0.5, options: .transitionFlipFromLeft, animations: {
      self.rootViewController = viewController
      }, completion: nil)
  }
}
