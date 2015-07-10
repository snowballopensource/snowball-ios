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
    label.textColor = UIColor.blackColor()
    return label
  }()

  let detailImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = UIViewContentMode.Bottom
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

    let margin: CGFloat = 35

    view.addSubview(detailImageView)
    layout(detailImageView, titleLabel) { (detailImageView, titleLabel) in
      detailImageView.left == detailImageView.superview!.left + margin
      detailImageView.top == titleLabel.bottom + margin
      detailImageView.right == detailImageView.superview!.right - margin
      detailImageView.bottom == detailImageView.superview!.bottom
    }
  }
}