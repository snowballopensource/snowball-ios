//
//  SnowballActionButton.swift
//  Snowball
//
//  Created by James Martinez on 2/25/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

class SnowballActionButton: UIButton {

  // MARK: Properties

  static let defaultHeight: CGFloat = 45

  private let gradient: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.colors = [
      UIColor(colorLiteralRed: 246/255.0, green: 245/255.0, blue: 23/255.0, alpha: 1).CGColor,
      UIColor(colorLiteralRed: 83/255.0, green: 253/255.0, blue: 143/255.0, alpha: 1).CGColor,
      UIColor(colorLiteralRed: 81/255.0, green: 213/255.0, blue: 236/255.0, alpha: 1).CGColor,
      UIColor(colorLiteralRed: 224/255.0, green: 81/255.0, blue: 236/255.0, alpha: 1).CGColor
    ]
    gradient.startPoint = CGPointZero
    gradient.endPoint = CGPoint(x: 1, y: 0)
    return gradient
  }()

  // MARK: Initializers

  init() {
    super.init(frame: CGRectZero)

    setTitleColor(UIColor.whiteColor(), forState: .Normal)
    titleLabel?.font = UIFont.SnowballFont.mediumFont.fontWithSize(20)

    clipsToBounds = true

    layer.cornerRadius = 13

    layer.insertSublayer(gradient, atIndex: 0)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()
    gradient.frame = bounds
  }
}