//
//  SnowballActionButton.swift
//  Snowball
//
//  Created by James Martinez on 2/25/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

enum SnowballActionButtonStyle {
  case gradient
  case bordered
}

class SnowballActionButton: UIButton {

  // MARK: Properties

  static let defaultHeight: CGFloat = 45

  private let gradient: CAGradientLayer = {
    let gradient = CAGradientLayer()
    gradient.colors = [
      UIColor(colorLiteralRed: 246/255.0, green: 245/255.0, blue: 23/255.0, alpha: 1).cgColor,
      UIColor(colorLiteralRed: 83/255.0, green: 253/255.0, blue: 143/255.0, alpha: 1).cgColor,
      UIColor(colorLiteralRed: 81/255.0, green: 213/255.0, blue: 236/255.0, alpha: 1).cgColor,
      UIColor(colorLiteralRed: 224/255.0, green: 81/255.0, blue: 236/255.0, alpha: 1).cgColor
    ]
    gradient.startPoint = CGPoint.zero
    gradient.endPoint = CGPoint(x: 1, y: 0)
    return gradient
  }()

  // MARK: Initializers

  init(style: SnowballActionButtonStyle = .gradient) {
    super.init(frame: CGRect.zero)

    setTitleColor(UIColor.white, for: UIControlState())
    titleLabel?.font = UIFont.SnowballFont.mediumFont.withSize(20)

    clipsToBounds = true

    layer.cornerRadius = 13

    if style == .gradient {
      layer.insertSublayer(gradient, at: 0)
    } else {
      layer.borderWidth = 2
      layer.borderColor = UIColor.white.cgColor
    }
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
