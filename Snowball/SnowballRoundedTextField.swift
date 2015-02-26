//
//  SnowballRoundedTextField.swift
//  Snowball
//
//  Created by James Martinez on 2/25/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class SnowballRoundedTextField: UITextField {

  // MARK: - Initializers

  override init() {
    super.init(frame: CGRectZero)

    layer.borderWidth = 2
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.cornerRadius = frame.height / 2
  }

  override func tintColorDidChange() {
    super.tintColorDidChange()

    layer.borderColor = tintColor?.CGColor
    textColor = tintColor
  }
}
