//
//  ColorSidePaginatorView.swift
//  Snowball
//
//  Created by James Martinez on 8/27/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

class ColorSidePaginatorView: PaginatorView {

  // MARK: Properties

  override var state: PaginatorState {
    didSet {
      switch state {
      case .Default:
        hidden = true
      case .InMotion:
        hidden = false
        backgroundColor = UIColor.lightGrayColor()
      case .Loading:
        setRandomColorAtIntervalsAnimated()
      }
    }
  }

  // MARK: Initializers

  init() {
    super.init(size: 60)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: Private

  func setRandomColorAtIntervalsAnimated() {
    UIView.animateWithDuration(0.3, animations: {
      self.layer.backgroundColor = UIColor.SnowballColor.randomColor().CGColor
    }) { _ in
      if self.state == .Loading {
        self.setRandomColorAtIntervalsAnimated()
      }
    }
  }
}
