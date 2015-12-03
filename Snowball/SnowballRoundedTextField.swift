//
//  SnowballRoundedTextField.swift
//  Snowball
//
//  Created by James Martinez on 2/25/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class SnowballRoundedTextField: UITextField {

  // MARK: - UIView

  override func tintColorDidChange() {
    super.tintColorDidChange()

    textColor = tintColor
  }


  // MARK: - Internal

  func setPlaceholder(placeholder: String, color: UIColor) {
    attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: color])
  }
}
