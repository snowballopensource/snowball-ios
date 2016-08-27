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
        colorView.backgroundColor = UIColor.lightGrayColor()
      case .Loading:
        setRandomColorAtIntervalsAnimated()
      }
    }
  }

  private let colorView = UIView()

  // MARK: Initializers

  init() {
    super.init(size: 60)
    addSubview(colorView)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIView

  override func layoutSubviews() {
    colorView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: ClipCollectionViewCell.defaultSize.width)
  }

  // MARK: Private

  func setRandomColorAtIntervalsAnimated() {
    UIView.animateWithDuration(0.3, animations: {
      self.colorView.layer.backgroundColor = UIColor.SnowballColor.randomColor().CGColor
    }) { _ in
      if self.state == .Loading {
        self.setRandomColorAtIntervalsAnimated()
      }
    }
  }
}
