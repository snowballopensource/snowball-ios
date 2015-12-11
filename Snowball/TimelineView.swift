//
//  TimelineView.swift
//  Snowball
//
//  Created by James Martinez on 12/10/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class TimelineView: UIView {

  // MARK: UIView

  override init(frame: CGRect) {
    super.init(frame: frame)

    backgroundColor = UIColor.purpleColor()
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}