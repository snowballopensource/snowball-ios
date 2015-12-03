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
    return 90
  }

  let descriptionLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 18)
    label.textColor = UIColor.blackColor()
    return label
  }()

  let textField: SnowballRoundedTextField = {
    let textField = SnowballRoundedTextField()
    textField.font = UIFont(name: UIFont.SnowballFont.regular, size: 22)
    return textField
    }()

  let bottomBorderLine: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.blackColor()
    return view
  }()

  // MARK: - Initializers

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)

    let margin: CGFloat = 25
    contentView.addSubview(descriptionLabel)
    constrain(descriptionLabel) { (descriptionLabel) in
      descriptionLabel.left == descriptionLabel.superview!.left + margin
      descriptionLabel.top == descriptionLabel.superview!.top + 10
    }

    contentView.addSubview(textField)
    constrain(textField, descriptionLabel) { (textField, descriptionLabel) in
      textField.left == textField.superview!.left + margin
      textField.top == descriptionLabel.bottom
      textField.right == textField.superview!.right - margin
      textField.height == 50
    }

    contentView.addSubview(bottomBorderLine)
    constrain(bottomBorderLine, textField) { bottomBorderLine, textField in
      bottomBorderLine.left == bottomBorderLine.superview!.left + margin
      bottomBorderLine.bottom == textField.bottom - 1
      bottomBorderLine.right == bottomBorderLine.superview!.right - margin
      bottomBorderLine.height == 1
    }
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
