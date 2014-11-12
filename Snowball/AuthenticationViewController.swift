//
//  AuthenticationViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/27/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class AuthenticationViewController: UIViewController {
  let signInButton = UIButton()
  let signUpButton = UIButton()

  func signInButtonTapped() {
    navigationController?.pushViewController(SignInViewController(), animated: true)
  }

  func signUpButtonTapped() {
    navigationController?.pushViewController(SignUpViewController(), animated: true)
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    let margin: Float = 20.0

    signInButton.setTitle(NSLocalizedString("Sign In"), forState: UIControlState.Normal)
    signInButton.setTitleColorWithAutomaticHighlightColor(color: UIColor.whiteColor())
    signInButton.backgroundColor = UIColor.SnowballColor.blue()
    signInButton.addTarget(self, action: "signInButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(signInButton)
    layout(signInButton) { (signInButton) in
      signInButton.left == signInButton.superview!.left + margin
      signInButton.right == signInButton.superview!.right - margin
      signInButton.bottom == signInButton.superview!.bottom - margin
      signInButton.height == 50
    }

    signUpButton.setTitle(NSLocalizedString("Sign Up"), forState: UIControlState.Normal)
    signUpButton.setTitleColorWithAutomaticHighlightColor(color: UIColor.whiteColor())
    signUpButton.backgroundColor = UIColor.SnowballColor.blue()
    signUpButton.addTarget(self, action: "signUpButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(signUpButton)
    layout(signUpButton, signInButton) { (signUpButton, signInButton) in
      signUpButton.left == signInButton.left
      signUpButton.right == signInButton.right
      signUpButton.bottom == signInButton.top - margin
      signUpButton.height == signInButton.height
    }
  }
}