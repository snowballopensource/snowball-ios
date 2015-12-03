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

  private let backgroundImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "onboard-splash")
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.clipsToBounds = true
    return imageView
  }()

  private let backgroundImageViewLogo: UIImageView = {
    let imageView = UIImageView()
    imageView.image = UIImage(named: "snowball-logo")
    imageView.contentMode = UIViewContentMode.Center
    return imageView
  }()

  private let signUpButton: SnowballRoundedButton = {
    let button = SnowballRoundedButton(style: SnowballRoundedButtonStyle.Rainbow)
    button.setTitle(NSLocalizedString("sign up", comment: ""), forState: UIControlState.Normal)
    return button
  }()

  private let signInButton: SnowballRoundedButton = {
    let button = SnowballRoundedButton(style: SnowballRoundedButtonStyle.Fill)
    button.tintColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
    button.setTitle(NSLocalizedString("sign in", comment: ""), forState: UIControlState.Normal)
    return button
  }()

  private let legalLabel: UILabel = {
    let label = UILabel()
    label.text = NSLocalizedString("by continuing you are agreeing to the snowball\nterms of use and privacy policy", comment: "")
    label.textAlignment = NSTextAlignment.Center
    label.textColor = UIColor.SnowballColor.grayColor
    label.font = UIFont(name: UIFont.SnowballFont.bold, size: 10)
    label.numberOfLines = 0
    return label
  }()

  private let termsButton = UIButton()

  private let privacyButton = UIButton()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(backgroundImageView)
    constrain(backgroundImageView) { (backgroundImageView) in
      backgroundImageView.left == backgroundImageView.superview!.left
      backgroundImageView.top == backgroundImageView.superview!.top
      backgroundImageView.right == backgroundImageView.superview!.right
      backgroundImageView.height == backgroundImageView.superview!.height
    }

    backgroundImageView.addSubview(backgroundImageViewLogo)
    view.addSubview(backgroundImageView)
    constrain(backgroundImageViewLogo) { (backgroundImageViewLogo) in
      backgroundImageViewLogo.left == backgroundImageViewLogo.superview!.left
      backgroundImageViewLogo.top == backgroundImageViewLogo.superview!.top
      backgroundImageViewLogo.right == backgroundImageViewLogo.superview!.right
      backgroundImageViewLogo.height == backgroundImageViewLogo.superview!.height / 2
    }

    let buttonMargin: CGFloat = 25

    signUpButton.addTarget(self, action: "signUpButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(signUpButton)
    constrain(signUpButton) { (signUpButton) in
      signUpButton.left == signUpButton.superview!.left + buttonMargin
      signUpButton.top == signUpButton.superview!.centerY + 40
      signUpButton.right == signUpButton.superview!.right - buttonMargin
      signUpButton.height == 50
    }

    signInButton.addTarget(self, action: "signInButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(signInButton)
    constrain(signInButton, signUpButton) { (signInButton, signUpButton) -> () in
      signInButton.left == signUpButton.left
      signInButton.top == signUpButton.bottom + buttonMargin
      signInButton.right == signUpButton.right
      signInButton.height == signUpButton.height
    }

    view.addSubview(legalLabel)
    constrain(legalLabel) { (legalLabel) in
      let margin: CGFloat = 45
      legalLabel.left == legalLabel.superview!.left + margin
      legalLabel.right == legalLabel.superview!.right - margin
      legalLabel.bottom == legalLabel.superview!.bottom - 30
    }

    termsButton.addTarget(self, action: "termsButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(termsButton)
    constrain(termsButton, legalLabel) { (termsButton, legalLabel) in
      termsButton.left == legalLabel.left
      termsButton.top == legalLabel.top
      termsButton.right == termsButton.superview!.centerX
      termsButton.bottom == legalLabel.bottom
    }

    privacyButton.addTarget(self, action: "privacyButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(privacyButton)
    constrain(privacyButton, legalLabel) { (privacyButton, legalLabel) in
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