//
//  CurrentUserTableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 1/27/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

protocol CurrentUserTableViewCellDelegate: class {
  func settingsButtonTapped()
}

class CurrentUserTableViewCell: UserTableViewCell {
  private let settingsButton = UIButton()
  var delegate: CurrentUserTableViewCellDelegate?

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    settingsButton.setImage(UIImage(named: "settings"), forState: UIControlState.Normal)
    settingsButton.addTarget(delegate, action: "settingsButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    contentView.addSubview(settingsButton)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    let margin: Float = 20
    layout(settingsButton) { (settingsButton) in
      settingsButton.right == settingsButton.superview!.right - margin
      settingsButton.centerY == settingsButton.superview!.centerY
      settingsButton.width == 44
      settingsButton.height == settingsButton.width
    }
  }
}
