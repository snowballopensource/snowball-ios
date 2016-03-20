//
//  TextFieldContainerView.swift
//  Snowball
//
//  Created by James Martinez on 2/25/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import UIKit

class TextFieldContainerView: UIView {

  // MARK: Properties

  static let defaultHeight: CGFloat = 50
  static let defaultSideMargin: CGFloat = 30
  static let defaultSpaceBetween: CGFloat = 18
  static let defaultSpaceBeforeButton: CGFloat = 40

  var hintLabel: UILabel? = nil
  let textField: UITextField = {
    let textField = UITextField()
    textField.font = UIFont.SnowballFont.regularFont.fontWithSize(16)
    textField.textColor = UIColor.blackColor()
    return textField
  }()
  let bottomLineView: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.blackColor()
    return view
  }()

  // MARK: Initializers

  init(showHintLabel: Bool = true, bottomLineHeight: CGFloat = 1) {
    super.init(frame: CGRectZero)

    addSubview(bottomLineView)
    constrain(bottomLineView) { bottomLineView in
      bottomLineView.left == bottomLineView.superview!.left
      bottomLineView.right == bottomLineView.superview!.right
      bottomLineView.height == bottomLineHeight
      bottomLineView.bottom == bottomLineView.superview!.bottom
    }

    addSubview(textField)

    if showHintLabel {
      hintLabel = UILabel()
      guard let hintLabel = hintLabel else { return }
      hintLabel.font = UIFont.SnowballFont.regularFont.fontWithSize(16)
      hintLabel.textColor = UIColor.blackColor()
      addSubview(hintLabel)

      constrain(hintLabel, textField) { hintLabel, textField in
        hintLabel.left == hintLabel.superview!.left
        hintLabel.baseline == textField.baseline
      }
      hintLabel.setContentCompressionResistancePriority(textField.contentCompressionResistancePriorityForAxis(.Horizontal) + 1, forAxis: .Horizontal)
      constrain(textField, hintLabel, bottomLineView) { textField, hintLabel, bottomLineView in
        textField.left == hintLabel.right + 20
        textField.top == textField.superview!.top
        textField.right == textField.superview!.right
        textField.bottom == bottomLineView.top
      }
    } else {
      constrain(textField, bottomLineView) { textField, bottomLineView in
        textField.left == textField.superview!.left
        textField.top == textField.superview!.top
        textField.right == textField.superview!.right
        textField.bottom == bottomLineView.top
      }
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Internal

  func configureText(hint hint: String?, placeholder: String?) {
    hintLabel?.text = hint
    if let placeholder = placeholder {
      textField.attributedPlaceholder = NSAttributedString(string: placeholder, attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.lightGrayColor])
    } else {
      textField.placeholder = nil
    }
  }

  func linkSizingWithTextFieldContainerView(textFieldContainerView: TextFieldContainerView) {
    guard let thisHintLabel = hintLabel, thatHintLabel = textFieldContainerView.hintLabel else { return }
    constrain(thisHintLabel, thatHintLabel) { thisHintLabel, thatHintLabel in
      thisHintLabel.width >= thatHintLabel.width
      thatHintLabel.width >= thisHintLabel.width
    }
  }
}