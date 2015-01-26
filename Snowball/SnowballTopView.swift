//
//  SnowballTopView.swift
//  Snowball
//
//  Created by James Martinez on 1/26/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

protocol SnowballTopViewDelegate: class {
  func snowballTopViewBackButtonTapped()
  func snowballTopViewForwardButtonTapped()
}

class SnowballTopView: UIView {
  private let backButton = UIButton()
  private let forwardButton = UIButton()
  var delegate: SnowballTopViewDelegate?
  class var defaultHeight: Float { return 65 }

  // MARK: - UIView

  override init(frame: CGRect) {
    super.init(frame: frame)

    let backImage = UIImage(named: "back")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    backButton.setImage(backImage, forState: UIControlState.Normal)
    backButton.imageView?.tintColor = UIColor.SnowballColor.grayColor
    backButton.addTarget(delegate, action: "snowballTopViewBackButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(backButton)

    let forwardImage = UIImage(named: "forward")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    forwardButton.setImage(forwardImage, forState: UIControlState.Normal)
    forwardButton.imageView?.tintColor = UIColor.SnowballColor.greenColor
    forwardButton.addTarget(delegate, action: "snowballTopViewForwardButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(forwardButton)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  convenience override init() {
    self.init(frame: CGRectZero)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    // width = 25 on each side of centered image in image view
    let backButtonWidth: CGFloat = (25 + backButton.imageView!.image!.size.width / 2) * 2
    backButton.frame = CGRect(x: 0, y: 0, width: backButtonWidth, height: bounds.height)
    let forwardButtonWidth: CGFloat = (25 + forwardButton.imageView!.image!.size.width / 2) * 2
    forwardButton.frame = CGRect(x: UIScreen.mainScreen().bounds.size.width - forwardButtonWidth, y: 0, width: forwardButtonWidth, height: bounds.height)
  }
}