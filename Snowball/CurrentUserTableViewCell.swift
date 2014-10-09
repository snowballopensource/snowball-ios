//
//  CurrentUserTableViewCell.swift
//  Snowball
//
//  Created by James Martinez on 10/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation

protocol CurrentUserTableViewCellDelegate: class {
  func settingsButtonTapped()
}

class CurrentUserTableViewCell: UserTableViewCell {
  private let settingsButton = UIButton()
  var delegate: CurrentUserTableViewCellDelegate?

  // MARK: -

  // MARK: UserTableViewCell

  override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    settingsButton.setTitle(NSLocalizedString("Settings"), forState: UIControlState.Normal)
    settingsButton.setTitleColorWithAutomaticHighlightColor(color: UIColor.SnowballColor.blue())
    settingsButton.addTarget(delegate, action: "settingsButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    contentView.addSubview(settingsButton)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    layout(settingsButton) { (settingsButton) in
      settingsButton.centerY == settingsButton.superview!.centerY
      settingsButton.right == settingsButton.superview!.right - 16
    }
  }

}