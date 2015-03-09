//
//  OnboardingViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/20/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class OnboardingViewController: UIViewController {

  // MARK: - Properties

  let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 32)
    label.textColor = UIColor.whiteColor()
    return label
  }()

  let detailLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.textAlignment = NSTextAlignment.Center
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 19)
    label.textColor = UIColor.whiteColor()
    return label
  }()

  let detailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = UIViewContentMode.ScaleAspectFit
    return imageView
  }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(titleLabel)
    layout(titleLabel) { (titleLabel) in
      titleLabel.centerX == titleLabel.superview!.centerX
      titleLabel.top == titleLabel.superview!.top + 70
    }

    let margin: CGFloat = 40
    view.addSubview(detailLabel)
    layout(detailLabel, titleLabel) { (detailLabel, titleLabel) in
      detailLabel.left == detailLabel.superview!.left + margin
      detailLabel.top == titleLabel.bottom + 10
      detailLabel.right == detailLabel.superview!.right - margin
    }

    view.addSubview(detailImageView)
    var originY: CGFloat = 300
    if isIphone4S {
      originY = 250
    }
    layout(detailImageView) { (detailImageView) in
      detailImageView.left == detailImageView.superview!.left
      detailImageView.top == detailImageView.superview!.top + originY
      detailImageView.right == detailImageView.superview!.right
      detailImageView.bottom == detailImageView.superview!.bottom
    }
  }

}