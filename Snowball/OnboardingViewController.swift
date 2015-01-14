//
//  OnboardingViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class OnboardingViewController: UIViewController {
  let topImageView = UIImageView()
  let topImageViewLogo = UIImageView()
  let signUpButton = UIButton()
  let signInButton = UIButton()
  let legalLabel = UILabel()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    topImageView.image = UIImage(named: "onboarding-image")
    topImageView.contentMode = UIViewContentMode.ScaleAspectFill
    topImageView.clipsToBounds = true
    view.addSubview(topImageView)
    layout(topImageView) { (topImageView) in
      topImageView.left == topImageView.superview!.left
      topImageView.top == topImageView.superview!.top
      topImageView.right == topImageView.superview!.right
      topImageView.height == Float(UIScreen.mainScreen().bounds.size.height / 2)
    }

    topImageViewLogo.image = UIImage(named: "snowball-logo")
    topImageViewLogo.contentMode = UIViewContentMode.Center
    topImageViewLogo.frame = topImageView.bounds
    topImageView.addSubview(topImageViewLogo)

    let buttonMargin: Float = 25

    signUpButton.setTitle(NSLocalizedString("sign up"), forState: UIControlState.Normal)
    signUpButton.setTitleColor(UIColor.SnowballColor.greenColor, forState: UIControlState.Normal)
    signUpButton.titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    signUpButton.alignLeft()
    signUpButton.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
    signUpButton.addTarget(self, action: "signUpButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(signUpButton)
    layout(signUpButton, topImageView) { (signUpButton, topImageView) in
      signUpButton.left == signUpButton.superview!.left + buttonMargin
      signUpButton.top == topImageView.bottom + 40
      signUpButton.right == signUpButton.superview!.right - buttonMargin
      signUpButton.height == 50
    }
    let chevronImage = UIImage(named: "chevron")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    let signUpChevron = UIImageView(image: chevronImage)
    signUpChevron.tintColor = UIColor.SnowballColor.greenColor
    signUpButton.addSubview(signUpChevron)
    layout(signUpChevron) { (signUpChevron) in
      signUpChevron.width == Float(chevronImage.size.width)
      signUpChevron.centerY == signUpChevron.superview!.centerY
      signUpChevron.right == signUpChevron.superview!.right - 25
      signUpChevron.height == Float(chevronImage.size.height)
    }

    signInButton.setTitle(NSLocalizedString("sign in"), forState: UIControlState.Normal)
    signInButton.setTitleColor(UIColor.SnowballColor.grayColor, forState: UIControlState.Normal)
    signInButton.titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    signInButton.alignLeft()
    signInButton.addTarget(self, action: "signInButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(signInButton)
    layout(signInButton, signUpButton) { (signInButton, signUpButton) -> () in
      signInButton.left == signUpButton.left
      signInButton.top == signUpButton.bottom + buttonMargin
      signInButton.right == signUpButton.right
      signInButton.height == signUpButton.height
    }
    let signInChevron = UIImageView(image: chevronImage)
    signInChevron.tintColor = UIColor.SnowballColor.grayColor
    signInButton.addSubview(signInChevron)
    layout(signInChevron) { (signInChevron) in
      signInChevron.width == Float(chevronImage.size.width)
      signInChevron.centerY == signInChevron.superview!.centerY
      signInChevron.right == signInChevron.superview!.right - 25
      signInChevron.height == Float(chevronImage.size.height)
    }

    legalLabel.text = NSLocalizedString("by continuing you are agreeing to the snowball terms of use and privacy policy")
    legalLabel.textColor = UIColor.SnowballColor.grayColor
    legalLabel.font = UIFont(name: UIFont.SnowballFont.bold, size: 10)
    legalLabel.numberOfLines = 0
    view.addSubview(legalLabel)
    layout(legalLabel) { (legalLabel) in
      let margin: Float = 45
      legalLabel.left == legalLabel.superview!.left + margin
      legalLabel.right == legalLabel.superview!.right - margin
      legalLabel.bottom == legalLabel.superview!.bottom - 30
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }

  override func viewWillDisappear(animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: animated)
    super.viewWillDisappear(animated)
  }

  // MARK: - Actions

  func signUpButtonTapped() {
    navigationController?.pushViewController(OnboardingSignUpViewController(), animated: true)
  }

  func signInButtonTapped() {
    navigationController?.pushViewController(OnboardingSignInViewController(), animated: true)
  }
}