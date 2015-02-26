//
//  WelcomeViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class WelcomeViewController: UIViewController {

  // MARK: - Properties

  private let topImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "welcome-image")
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()

  private let topImageViewLogo: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "snowball-logo")
    imageView.contentMode = UIViewContentMode.Center
    return imageView
  }()

  let signUpButton: UIButton = {
    let button = UIButton()
    button.setTitle(NSLocalizedString("sign up"), forState: UIControlState.Normal)
    button.setTitleColor(UIColor.SnowballColor.greenColor, forState: UIControlState.Normal)
    button.titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    button.alignLeft(insetWidth: 20)
    button.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
    return button
  }()

  let signInButton: UIButton = {
    let button = UIButton()
    button.setTitle(NSLocalizedString("sign in"), forState: UIControlState.Normal)
    button.setTitleColor(UIColor.SnowballColor.grayColor, forState: UIControlState.Normal)
    button.titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    button.alignLeft(insetWidth: 20)
    return button
  }()

  let legalLabel: UILabel = {
    let label = UILabel()
    label.text = NSLocalizedString("by continuing you are agreeing to the snowball\nterms of use and privacy policy")
    label.textAlignment = NSTextAlignment.Center
    label.textColor = UIColor.SnowballColor.grayColor
    label.font = UIFont(name: UIFont.SnowballFont.bold, size: 10)
    label.numberOfLines = 0
    return label
  }()

  let termsButton = UIButton()

  let privacyButton = UIButton()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(topImageView)
    layout(topImageView) { (topImageView) in
      topImageView.left == topImageView.superview!.left
      topImageView.top == topImageView.superview!.top
      topImageView.right == topImageView.superview!.right
      topImageView.height == Float(UIScreen.mainScreen().bounds.size.height / 2)
    }

    topImageViewLogo.frame = topImageView.bounds
    topImageView.addSubview(topImageViewLogo)

    let buttonMargin: Float = 25

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

    view.addSubview(legalLabel)
    layout(legalLabel) { (legalLabel) in
      let margin: Float = 45
      legalLabel.left == legalLabel.superview!.left + margin
      legalLabel.right == legalLabel.superview!.right - margin
      legalLabel.bottom == legalLabel.superview!.bottom - 30
    }

    termsButton.addTarget(self, action: "termsButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(termsButton)
    layout(termsButton, legalLabel) { (termsButton, legalLabel) in
      termsButton.left == legalLabel.left
      termsButton.top == legalLabel.top
      termsButton.right == termsButton.superview!.centerX
      termsButton.bottom == legalLabel.bottom
    }

    privacyButton.addTarget(self, action: "privacyButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(privacyButton)
    layout(privacyButton, legalLabel) { (privacyButton, legalLabel) in
      privacyButton.left == privacyButton.superview!.centerX
      privacyButton.top == legalLabel.top
      privacyButton.right == legalLabel.right
      privacyButton.bottom == legalLabel.bottom
    }
  }

  // MARK: - Private

  @objc private func signUpButtonTapped() {
    navigationController?.pushViewController(SignUpViewController(), animated: true)
  }

  @objc private func signInButtonTapped() {
    navigationController?.pushViewController(SignInViewController(), animated: true)
  }

  @objc private func termsButtonTapped() {
    navigationController?.pushViewController(TermsViewController(), animated: true)
  }

  @objc private func privacyButtonTapped() {
    navigationController?.pushViewController(PrivacyPolicyViewController(), animated: true)
  }
}