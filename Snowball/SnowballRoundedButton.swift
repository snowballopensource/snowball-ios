//
//  SnowballRoundedButton.swift
//  Snowball
//
//  Created by James Martinez on 2/25/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

enum SnowballRoundedButtonStyle {
  case Border
  case Fill
}

class SnowballRoundedButton: UIButton {

  // MARK: - Properties

  private let style: SnowballRoundedButtonStyle

  // MARK: - Initializers

  convenience init() {
    self.init(style: .Border)
  }

  init(style: SnowballRoundedButtonStyle) {
    self.style = style

    super.init(frame: CGRectZero)

    if style == .Border {
      layer.borderWidth = 2
    }
    titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    titleLabel?.textAlignment = .Center
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.cornerRadius = frame.height / 4
  }

  override func tintColorDidChange() {
    super.tintColorDidChange()

    switch(style) {
    case .Border:
      layer.borderColor = tintColor?.CGColor
      setTitleColor(tintColor, forState: UIControlState.Normal)
    case .Fill:
      backgroundColor = tintColor
      setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    }
  }
}