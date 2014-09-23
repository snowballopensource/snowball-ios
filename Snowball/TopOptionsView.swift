//
//  TopOptionsView.swift
//  Snowball
//
//  Created by James Martinez on 9/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class TopOptionsView: UIView {

  // MARK: UIView

  override init(frame: CGRect) {
    super.init(frame: frame)
    backgroundColor = UIColor.lightGrayColor()
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  convenience override init() {
    self.init(frame: CGRectZero)
  }

}
