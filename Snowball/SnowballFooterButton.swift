//
//  SnowballFooterButton.swift
//  Snowball
//
//  Created by James Martinez on 3/10/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class SnowballFooterButton: UIButton {

  // MARK: - Properties

  private var rightImageView = UIImageView()

  // MARK: - Initializers

  init(rightImage: UIImage? = nil) {
    super.init(frame: CGRectZero)

    backgroundColor = UIColor.SnowballColor.blueColor
    titleLabel?.font = UIFont(name: UIFont.SnowballFont.bold, size: 19)
    alignLeft(insetWidth: 20)

    if let rightImage = rightImage {
      rightImageView.image = rightImage.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
      addSubview(rightImageView)
    }

    tintColor = UIColor.whiteColor()
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    if let rightImage = rightImageView.image {
      let margin: CGFloat = 20
      rightImageView.frame = CGRect(x: bounds.width - rightImage.size.width - margin, y: CGRectGetMidY(bounds) - rightImage.size.height / 2, width: rightImage.size.width, height: rightImage.size.height)
    }
  }

  override func tintColorDidChange() {
    super.tintColorDidChange()

    setTitleColor(tintColor, forState: UIControlState.Normal)
    rightImageView.tintColor = tintColor
  }

  // MARK: - Internal

  func setupDefaultLayout() {
    let height: Float = 50

    layout(self) { (footerButton) in
      footerButton.left == footerButton.superview!.left
      footerButton.bottom == footerButton.superview!.bottom
      footerButton.right == footerButton.superview!.right
      footerButton.height == height
    }
  }
}