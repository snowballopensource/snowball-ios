//
//  SnowballTopView.swift
//  Snowball
//
//  Created by James Martinez on 1/26/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

@objc protocol SnowballTopViewDelegate: class {
  optional func snowballTopViewLeftButtonTapped()
  optional func snowballTopViewRightButtonTapped()
}

enum SnowballTopViewButtonType {
  case Back
  case Forward
  case Camera
  case AddFriends
  case Save
  case ChangeCamera
  case Friends

  // MARK: - Properties

  var button: UIButton {
    let button = UIButton()
    var image: UIImage?
    if let imageName = imageName {
      image = UIImage(named: imageName)
    }
    if let color = color {
      image = image?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
      button.imageView?.tintColor = color
      button.setTitleColor(color, forState: UIControlState.Normal)
    }
    button.setImage(image, forState: UIControlState.Normal)
    button.setTitle(title, forState: UIControlState.Normal)
    return button
  }

  private var imageName: String? {
    switch self {
    case .Back: return "back"
    case .Forward: return "forward"
    case .Camera: return "camera"
    case .AddFriends: return "add-friends"
    case .ChangeCamera: return "change-camera"
    case .Friends: return "friends"
    default: return nil
    }
  }

  private var color: UIColor? {
    switch self {
    case .Forward: return UIColor.SnowballColor.greenColor
    case .AddFriends: return nil
    case .Save: return UIColor.SnowballColor.greenColor
    case .ChangeCamera: return UIColor.whiteColor()
    case .Friends: return UIColor.whiteColor()
    default: return UIColor.blackColor()
    }
  }

  private var title: String? {
    switch self {
    case .Save: return "Save"
    default: return nil
    }
  }
}

class SnowballTopView: UIView {

  // MARK: - Properties

  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 26)
    return label
  }()

  private var leftButton: UIButton?

  private var rightButton: UIButton?

  var delegate: SnowballTopViewDelegate?

  // MARK: - Initializers

  convenience init(leftButtonType: SnowballTopViewButtonType?, rightButtonType: SnowballTopViewButtonType?, title: String = "") {
    self.init(frame: CGRectZero)

    if let leftButtonType = leftButtonType {
      leftButton = leftButtonType.button
      leftButton!.addTarget(delegate, action: "snowballTopViewLeftButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
      addSubview(leftButton!)
    }
    if let rightButtonType = rightButtonType {
      rightButton = rightButtonType.button
      rightButton!.addTarget(delegate, action: "snowballTopViewRightButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
      addSubview(rightButton!)
    }
    titleLabel.text = NSLocalizedString(title)
    addSubview(titleLabel)
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()
    let width: CGFloat = 20 // 20 on each side of centered image in image view
    if let leftButton = leftButton {
      var leftButtonWidth: CGFloat
      if let image = leftButton.imageView?.image {
        leftButtonWidth = (width + image.size.width / 2) * 2
      } else {
        leftButtonWidth = 84
      }
      leftButton.frame = CGRect(x: 0, y: 0, width: leftButtonWidth, height: bounds.height)
    }
    if let rightButton = rightButton {
      var rightButtonWidth: CGFloat
      if let image = rightButton.imageView?.image {
        rightButtonWidth = (width + rightButton.imageView!.image!.size.width / 2) * 2
      } else {
        rightButtonWidth = 84
      }
      rightButton.frame = CGRect(x: UIScreen.mainScreen().bounds.size.width - rightButtonWidth, y: 0, width: rightButtonWidth, height: bounds.height)
    }
    layout(titleLabel) { (titleLabel) in
      titleLabel.left == titleLabel.superview!.left + 75
      titleLabel.centerY == titleLabel.superview!.centerY
    }
  }

  override func pointInside(point: CGPoint, withEvent event: UIEvent?) -> Bool {
    if let leftButtonFrame = leftButton?.frame {
      if CGRectContainsPoint(leftButtonFrame, point) {
        return true
      }
    }
    if let rightButtonFrame = rightButton?.frame {
      if CGRectContainsPoint(rightButtonFrame, point) {
        return true
      }
    }
    return false
  }

  // MARK: - Internal

  func setupDefaultLayout() {
    let height: Float = 65

    layout(self) { (topBar) in
      topBar.left == topBar.superview!.left
      topBar.top == topBar.superview!.top
      topBar.right == topBar.superview!.right
      topBar.height == height
    }
  }

  func setHidden(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.setHidden(hidden, animated: false)
      }
    } else {
      if hidden {
        if frame.origin.y >= 0 {
          frame = CGRect(x: frame.origin.x, y: frame.origin.y - frame.size.height, width: frame.size.width, height: frame.size.height)
        }
      } else {
        if frame.origin.y < 0 {
          frame = CGRect(x: frame.origin.x, y: frame.origin.y + frame.size.height, width: frame.size.width, height: frame.size.height)
        }
      }
    }
  }
}