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