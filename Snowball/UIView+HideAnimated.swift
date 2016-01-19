//
//  UIView+HideAnimated.swift
//  Snowball
//
//  Created by James Martinez on 1/18/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
  func setHidden(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.setHidden(hidden, animated: false)
      }
    } else {
      alpha = CGFloat(!hidden)
    }
  }
}