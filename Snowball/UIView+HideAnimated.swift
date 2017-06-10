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
  func setHidden(_ hidden: Bool, animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.4, animations: {
        self.setHidden(hidden, animated: false)
      }) 
    } else {
      alpha = hidden ? 0 : 1
    }
  }
}
