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

  private let signUpButton: SnowballRoundedButton = {
    let button = SnowballRoundedButton()
    button.tintColor = UIColor.SnowballColor.blueColor
    button.showChevron = true
    button.setTitle(NSLocalizedString("sign up", comment: ""), forState: UIControlState.Normal)
    return button
  }()

  private let signInButton: SnowballRoundedButton = {
    let button = SnowballRoundedButton()
    button.tintColor = UIColor.SnowballColor.grayColor
    button.showChevron = true
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

  private let kHasSeenOnboardingKey = "HasSeenOnboarding"
  var hasSeenOnboarding: Bool {
    get {
      return NSUserDefaults.standardUserDefaults().objectForKey(kHasSeenOnboardingKey) as? Bool ?? false
    }
    set {
      NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: kHasSeenOnboardingKey)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }

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

    signInButton.addTarget(self, action: "signInButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(signInButton)
    layout(signInButton, signUpButton) { (signInButton, signUpButton) -> () in
      signInButton.left == signUpButton.left
      signInButton.top == signUpButton.bottom + buttonMargin
      signInButton.right == signUpButton.right
      signInButton.height == signUpButton.height
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

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)

    if !hasSeenOnboarding {
      presentViewController(OnboardingPageViewController(), animated: true) {
        self.hasSeenOnboarding = true
      }
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