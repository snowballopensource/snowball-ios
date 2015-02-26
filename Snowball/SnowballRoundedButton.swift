//
//  SnowballRoundedButton.swift
//  Snowball
//
//  Created by James Martinez on 2/25/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class SnowballRoundedButton: UIButton {

  private var chevronImageView: UIImageView = {
    let chevronImage = UIImage(named: "chevron")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    return UIImageView(image: chevronImage)
  }()

  var showChevron: Bool = false {
    didSet {
      chevronImageView.hidden = !showChevron
    }
  }

  // MARK: - Initializers

  override init() {
    super.init(frame: CGRectZero)

    layer.borderWidth = 2
    titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    alignLeft(insetWidth: 20)
    chevronImageView.hidden = true
    addSubview(chevronImageView)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.cornerRadius = frame.height / 2

    let chevronImage = chevronImageView.image!
    let margin: CGFloat = 20
    chevronImageView.frame = CGRect(x: bounds.width - chevronImage.size.width - margin, y: CGRectGetMidY(bounds) - chevronImage.size.height / 2, width: chevronImage.size.width, height: chevronImage.size.height)
  }

  override func tintColorDidChange() {
    super.tintColorDidChange()

    layer.borderColor = tintColor?.CGColor
    setTitleColor(tintColor, forState: UIControlState.Normal)
    chevronImageView.tintColor = tintColor
  }
}