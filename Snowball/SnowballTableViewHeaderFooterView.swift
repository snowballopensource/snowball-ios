//
//  SnowballTableViewHeaderFooterView.swift
//  Snowball
//
//  Created by James Martinez on 1/27/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class SnowballTableViewHeaderFooterView: UITableViewHeaderFooterView {
  let titleLabel = UILabel()

  override convenience init() {
    self.init(frame: CGRectZero)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    contentView.backgroundColor = UIColor.whiteColor()
    titleLabel.font = UIFont(name: UIFont.SnowballFont.bold, size: 11)
    contentView.addSubview(titleLabel)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    let margin: Float = 20

    layout(titleLabel) { (titleLabel) in
      titleLabel.left == titleLabel.superview!.left + margin
      titleLabel.centerY == titleLabel.superview!.centerY
    }
  }

  // MARK: - Required

  override class func height() -> CGFloat {
    return 25
  }
}
