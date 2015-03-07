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
    return 60
  }

  let textField: SnowballRoundedTextField = {
    let textField = SnowballRoundedTextField()
    textField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    textField.tintColor = UIColor.SnowballColor.greenColor
    return textField
    }()

  // MARK: - Initializers

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    contentView.addSubview(textField)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    let margin: Float = 20

    layout(textField) { (textField) in
      textField.left == textField.superview!.left + margin
      textField.top == textField.superview!.top + 10
      textField.right == textField.superview!.right - margin
      textField.height == 50
    }
  }
}
