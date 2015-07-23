//
//  SnowballRoundedButton.swift
//  Snowball
//
//  Created by James Martinez on 2/25/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

enum SnowballRoundedButtonStyle {
  case Border
  case Fill
}

class SnowballRoundedButton: UIButton {

  // MARK: - Properties

  private let style: SnowballRoundedButtonStyle

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

  convenience init() {
    self.init(style: .Border)
  }

  init(style: SnowballRoundedButtonStyle) {
    self.style = style

    super.init(frame: CGRectZero)

    if style == .Border {
      layer.borderWidth = 2
    }
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

    switch(style) {
    case .Border:
      layer.borderColor = tintColor?.CGColor
      setTitleColor(tintColor, forState: UIControlState.Normal)
      chevronImageView.tintColor = tintColor
    case .Fill:
      backgroundColor = tintColor
      setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
      chevronImageView.tintColor = UIColor.whiteColor()
    }
  }
}