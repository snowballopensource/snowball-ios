//
//  SegmentedControl.swift
//  Snowball
//
//  Created by James Martinez on 3/14/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class SegmentedControl: UIControl {

  // MARK: Properties

  let labels: [UILabel]
  let underlines: [UIView]
  var selectedIndex = 0 {
    didSet {
      sendActionsForControlEvents(.ValueChanged)
      highlightIndex(selectedIndex)
    }
  }

  // MARK: Initializers

  init(titles: [String]) {
    var labels = [UILabel]()
    var underlines = [UIView]()
    for title in titles {
      let label = UILabel(frame: CGRectZero)
      label.text = title
      label.textAlignment = .Center
      label.font = UIFont.SnowballFont.mediumFont.fontWithSize(17)
      labels.append(label)

      let underline = UIView()
      underline.backgroundColor = UIColor.blackColor()
      underlines.append(underline)
    }
    self.labels = labels
    self.underlines = underlines

    super.init(frame: CGRectZero)

    var previousLabel: UIView? = nil
    for var i = 0; i < labels.count; i++ {
      let label = labels[i]
      let underline = underlines[i]
      addSubview(label)
      addSubview(underline)
      constrain(label, underline) { label, underline in
        let width = label.superview!.width / CGFloat(labels.count)

        label.top == label.superview!.top
        label.width == width
        label.bottom == label.superview!.bottom - 2

        underline.left == label.left + 3
        underline.bottom == underline.superview!.bottom
        underline.height == 2
        underline.width == width - 6
      }
      if previousLabel == nil {
        constrain(label) { label in
          label.left == label.superview!.left
        }
      } else {
        constrain(label, previousLabel!) { label, previousLabel in
          label.left == previousLabel.right
        }
      }
      previousLabel = label
    }

    highlightIndex(0)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIControl

  override func beginTrackingWithTouch(touch: UITouch, withEvent event: UIEvent?) -> Bool {
    super.beginTrackingWithTouch(touch, withEvent: event)

    let touchPoint = touch.locationInView(self)

    for var i = 0; i < labels.count; i++ {
      let label = labels[i]
      if label.frame.contains(touchPoint) && selectedIndex != i {
        selectedIndex = i
      }
    }

    return false
  }

  // MARK: Private

  private func highlightIndex(index: Int) {
    for var i = 0; i < labels.count; i++ {
      let label = labels[i]
      let underline = underlines[i]
      if index == i {
        label.textColor = UIColor.blackColor()
        underline.backgroundColor = UIColor.blackColor()
      } else {
        label.textColor = UIColor.SnowballColor.lightGrayColor
        underline.backgroundColor = UIColor.SnowballColor.lightGrayColor
      }
    }
  }
}