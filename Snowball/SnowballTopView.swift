//
//  SnowballTopView.swift
//  Snowball
//
//  Created by James Martinez on 1/26/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

protocol SnowballTopViewDelegate: class {
  func snowballTopViewLeftButtonTapped()
  func snowballTopViewRightButtonTapped()
}

enum SnowballTopViewButtonType {
  case Back
  case Forward
  case Camera
  case AddFriends

  var button: UIButton {
    let button = UIButton()
    let image = UIImage(named: imageName)!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    button.setImage(image, forState: UIControlState.Normal)
    button.imageView?.tintColor = color
    return button
  }

  private var imageName: String {
    switch self {
    case .Back: return "back"
    case .Forward: return "foward"
    // case .Camera: return "camera"
    // case .AddFriends: return "add-friends"
    default: return "back"
    }
  }

  private var color: UIColor {
    switch self {
    case .Back: return UIColor.SnowballColor.grayColor
    case .Forward: return UIColor.SnowballColor.greenColor
    default: return UIColor.blackColor()
    }
  }
}

class SnowballTopView: UIView {
  private var leftButton: UIButton?
  private var rightButton: UIButton?
  var delegate: SnowballTopViewDelegate?

  // MARK: - UIView

  convenience init(leftButtonType: SnowballTopViewButtonType?, rightButtonType: SnowballTopViewButtonType?) {
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
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    // width = 25 on each side of centered image in image view
    if let leftButton = leftButton {
      let leftButtonWidth: CGFloat = (25 + leftButton.imageView!.image!.size.width / 2) * 2
      leftButton.frame = CGRect(x: 0, y: 0, width: leftButtonWidth, height: bounds.height)
    }
    if let rightButton = rightButton {
      let rightButtonWidth: CGFloat = (25 + rightButton.imageView!.image!.size.width / 2) * 2
      rightButton.frame = CGRect(x: UIScreen.mainScreen().bounds.size.width - rightButtonWidth, y: 0, width: rightButtonWidth, height: bounds.height)
    }
  }

  // MARK: - Convenience

  func setupDefaultLayout() {
    let height: Float = 65

    layout(self) { (topBar) in
      topBar.left == topBar.superview!.left
      topBar.top == topBar.superview!.top
      topBar.right == topBar.superview!.right
      topBar.height == height
    }
  }
}