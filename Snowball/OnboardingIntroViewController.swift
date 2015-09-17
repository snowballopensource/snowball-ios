//
//  OnboardingIntroViewController.swift
//  Snowball
//
//  Created by James Martinez on 7/10/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class OnboardingIntroViewController: UIViewController {
  let introImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "onboard-splash")
    return imageView
    }()
  let logoImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "snowball-logo")
    imageView.contentMode = UIViewContentMode.Center
    return imageView
    }()
  let arrowImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "onboarding-chevron")
    imageView.contentMode = UIViewContentMode.Center
    return imageView
    }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(introImageView)
    layout(introImageView) { (introImageView) in
      introImageView.left == introImageView.superview!.left
      introImageView.top == introImageView.superview!.top
      introImageView.width == introImageView.superview!.width
      introImageView.height == introImageView.superview!.height
    }

    view.addSubview(logoImageView)
    layout(logoImageView) { (logoImageView) in
      logoImageView.left == logoImageView.superview!.left
      logoImageView.top == logoImageView.superview!.top
      logoImageView.width == logoImageView.superview!.width
      logoImageView.height == logoImageView.superview!.height / 2
    }

    view.addSubview(arrowImageView)
    layout(arrowImageView) { (arrowImageView) in
      arrowImageView.left == arrowImageView.superview!.left
      arrowImageView.top == arrowImageView.superview!.centerX + 50
      arrowImageView.width == arrowImageView.superview!.width
      arrowImageView.height == arrowImageView.superview!.height
    }
    UIView.animateWithDuration(1, delay: 0, options: [UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.Repeat, UIViewAnimationOptions.CurveLinear], animations: { () -> Void in
      self.arrowImageView.alpha = 0.5
      }, completion: nil)
  }
}
