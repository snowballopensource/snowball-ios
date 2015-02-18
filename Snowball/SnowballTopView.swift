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

  var button: UIButton {
    let button = UIButton()
    var image = UIImage(named: imageName)!
    if let color = color {
      image = image.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
      button.imageView?.tintColor = color
    }
    button.setImage(image, forState: UIControlState.Normal)
    return button
  }

  private var imageName: String {
    switch self {
    case .Back: return "back"
    case .Forward: return "forward"
    case .Camera: return "camera"
    case .AddFriends: return "add-friends"
    default: return "back"
    }
  }

  private var color: UIColor? {
    switch self {
    case .Forward: return UIColor.SnowballColor.greenColor
    case .AddFriends: return nil
    default: return UIColor.blackColor()
    }
  }
}

class SnowballTopView: UIView {
  private var titleLabel = UILabel()
  private var leftButton: UIButton?
  private var rightButton: UIButton?
  var delegate: SnowballTopViewDelegate?

  // MARK: - UIView

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
    titleLabel.font = UIFont(name: UIFont.SnowballFont.regular, size: 26)
    addSubview(titleLabel)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    // width = 20 on each side of centered image in image view
    let width: CGFloat = 20
    if let leftButton = leftButton {
      let leftButtonWidth: CGFloat = (width + leftButton.imageView!.image!.size.width / 2) * 2
      leftButton.frame = CGRect(x: 0, y: 0, width: leftButtonWidth, height: bounds.height)
    }
    if let rightButton = rightButton {
      let rightButtonWidth: CGFloat = (width + rightButton.imageView!.image!.size.width / 2) * 2
      rightButton.frame = CGRect(x: UIScreen.mainScreen().bounds.size.width - rightButtonWidth, y: 0, width: rightButtonWidth, height: bounds.height)
    }
    layout(titleLabel) { (titleLabel) in
      titleLabel.left == titleLabel.superview!.left + 75
      titleLabel.centerY == titleLabel.superview!.centerY
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