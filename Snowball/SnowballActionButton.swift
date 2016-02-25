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
    gradient.colors = [UIColor(hex: "#F6F517").CGColor, UIColor(hex: "#53FD8F").CGColor, UIColor(hex: "#51D5EC").CGColor, UIColor(hex: "#E051EC").CGColor]
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