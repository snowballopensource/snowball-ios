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
  case BackWhite
  case Forward
  case Camera
  case AddFriends
  case Save
  case ChangeCamera
  case Friends
  case Skip

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
    case .BackWhite: return "back"
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
    case .BackWhite: return UIColor.whiteColor()
    case .Forward: return UIColor.SnowballColor.blueColor
    case .AddFriends: return nil
    case .Save: return UIColor.SnowballColor.blueColor
    case .ChangeCamera: return UIColor.whiteColor()
    case .Friends: return UIColor.whiteColor()
    case .Skip: return UIColor.SnowballColor.blueColor
    default: return UIColor.blackColor()
    }
  }

  private var title: String? {
    switch self {
    case .Save: return NSLocalizedString("Save", comment: "")
    case .Skip: return NSLocalizedString("Skip", comment: "")
    default: return nil
    }
  }
}

class SnowballTopView: UIView {

  // MARK: - Properties

  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 26)
    label.textAlignment = NSTextAlignment.Center
    return label
  }()

  private var leftButton: UIButton?

  private var rightButton: UIButton?

  private var rightButtonSpinner: UIActivityIndicatorView?

  private var constraintGroup = ConstraintGroup()

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
      rightButtonSpinner = UIActivityIndicatorView()
      rightButtonSpinner?.color = UIColor.SnowballColor.blueColor
      addSubview(rightButtonSpinner!)
    }
    titleLabel.text = title
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
      if let _ = rightButton.imageView?.image {
        rightButtonWidth = (width + rightButton.imageView!.image!.size.width / 2) * 2
      } else {
        rightButtonWidth = 84
      }
      rightButton.frame = CGRect(x: frame.width - rightButtonWidth, y: 0, width: rightButtonWidth, height: bounds.height)
      rightButtonSpinner?.center = rightButton.center
    }
    titleLabel.frame = CGRect(x: 0, y: 0, width: frame.width, height: frame.height)
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
    setupLayout(hidden: false)
  }

  func setHidden(hidden: Bool, animated: Bool) {
    if animated {
      UIView.animateWithDuration(0.4) {
        self.setHidden(hidden, animated: false)
      }
    } else {
      setupLayout(hidden: hidden)
      layoutIfNeeded()
    }
  }

  func spinRightButton(spin: Bool) {
    if spin {
      rightButton?.enabled = false
      rightButtonSpinner?.alpha = 0.0
      rightButtonSpinner?.startAnimating()
    }
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      var rightButtonAlpha: CGFloat = 0.0
      var rightButtonSpinnerAlpha: CGFloat = 0.0
      if spin {
        rightButtonSpinnerAlpha = 1.0
      } else {
        rightButtonAlpha = 1.0
      }
      self.rightButton?.alpha = rightButtonAlpha
      self.rightButtonSpinner?.alpha = rightButtonSpinnerAlpha
    }) { (completed) -> Void in
      if !spin {
        self.rightButton?.enabled = true
        self.rightButtonSpinner?.stopAnimating()
      }
    }
  }

  // MARK: - Private

  private func setupLayout(hidden hidden: Bool) {
    constraintGroup = constrain(self, replace: constraintGroup) { view in
      view.left == view.superview!.left
      view.width == view.superview!.width
      let height: CGFloat = 65.0
      view.height == height
      if hidden {
        view.top == view.superview!.top - height
      } else {
        view.top == view.superview!.top
      }
    }
  }
}