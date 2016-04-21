//
//  FormTextField.swift
//  Snowball
//
//  Created by James Martinez on 4/21/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

class FormTextField: UITextField {

  // MARK: Properties

  static let defaultHeight: CGFloat = 50
  static let defaultSideMargin: CGFloat = 30
  static let defaultSpaceBetween: CGFloat = 18
  static let defaultSpaceBeforeButton: CGFloat = 40

  var hint: String? {
    get {
      return hintLabel.text
    }
    set {
      hintLabel.text = newValue
    }
  }

  var hintWidth: CGFloat = 0

  private let hintLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.SnowballFont.regularFont.fontWithSize(16)
    label.textColor = UIColor.blackColor()
    return label
  }()

  private let bottomBorder: CALayer = {
    let layer = CALayer()
    layer.backgroundColor = UIColor.blackColor().CGColor
    return layer
  }()
  private let bottomBorderWidth: CGFloat = 1

  // MARK: Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    font = UIFont.SnowballFont.regularFont.fontWithSize(16)
    textColor = UIColor.blackColor()

    leftView = hintLabel
    leftViewMode = .Always

    layer.addSublayer(bottomBorder)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func drawRect(rect: CGRect) {
    super.drawRect(rect)

    bottomBorder.frame = CGRectMake(0, rect.height - bottomBorderWidth, rect.width, bottomBorderWidth)
  }

  // MARK: UITextField

  override func leftViewRectForBounds(bounds: CGRect) -> CGRect {
    return CGRect(x: 0, y: 0, width: hintWidth + 20, height: bounds.height)
  }

  // MARK: Internal

  static func linkFormTextFieldsHintSizing(textFields: [FormTextField]) {
    var widestHintWidth: CGFloat = 0
    for textField in textFields {
      let hintWidth = textField.hintLabel.intrinsicContentSize().width
      if widestHintWidth < hintWidth {
        widestHintWidth = hintWidth
      }
    }
    for textField in textFields {
      textField.hintWidth = widestHintWidth
    }
  }
}
