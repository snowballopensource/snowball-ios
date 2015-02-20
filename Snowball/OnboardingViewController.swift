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
    let titleLabel = UILabel()
    titleLabel.font = UIFont(name: UIFont.SnowballFont.regular, size: 32)
    titleLabel.textColor = UIColor.whiteColor()
    return titleLabel
  }()

  let detailLabel: UILabel = {
    let detailLabel = UILabel()
    detailLabel.numberOfLines = 0
    detailLabel.textAlignment = NSTextAlignment.Center
    detailLabel.font = UIFont(name: UIFont.SnowballFont.regular, size: 19)
    detailLabel.textColor = UIColor.whiteColor()
    return detailLabel
  }()

  let detailImageView: UIImageView = {
    let detailImageView = UIImageView()
    detailImageView.contentMode = UIViewContentMode.Top
    return detailImageView
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
    layout(detailImageView) { (detailImageView) in
      detailImageView.left == detailImageView.superview!.left
      detailImageView.top == detailImageView.superview!.top + 240
      detailImageView.right == detailImageView.superview!.right
      detailImageView.bottom == detailImageView.superview!.bottom
    }
  }

}