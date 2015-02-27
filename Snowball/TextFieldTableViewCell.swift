//
//  TextFieldTableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 2/8/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class TextFieldTableViewCell: UITableViewCell {

  // MARK: - Properties

  class var height: CGFloat {
    return 65
  }

  let textFieldLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.bold, size: 11)
    return label
    }()

  let textField: UITextField = {
    let textField = UITextField()
    textField.font = UIFont(name: UIFont.SnowballFont.regular, size: 26)
    textField.textColor = UIColor.SnowballColor.greenColor
    textField.alignLeft(insetWidth: 0)
    return textField
    }()

  // MARK: - Initializers

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(textFieldLabel)
    contentView.addSubview(textField)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    let margin: Float = 20
    layout(textFieldLabel) { (textFieldLabel) in
      textFieldLabel.left == textFieldLabel.superview!.left + margin
      textFieldLabel.top == textFieldLabel.superview!.top + 10
    }

    layout(textField, textFieldLabel) { (textField, textFieldLabel) in
      textField.left == textField.superview!.left + margin
      textField.top == textFieldLabel.bottom + 10
      textField.right == textField.superview!.right - margin
      textField.height == 30
    }
  }
}
