//
//  SignInViewController.swift
//  Snowball
//
//  Created by James Martinez on 11/12/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class SignInViewController: UIViewController {
  let usernameTextField = UITextField()
  let passwordTextField = UITextField()
  let signInButton = UIButton()

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    title = NSLocalizedString("Sign In")

    let margin: Float = 20.0

    usernameTextField.placeholder = NSLocalizedString("Username")
    usernameTextField.borderStyle = UITextBorderStyle.RoundedRect
    view.addSubview(usernameTextField)
    layout(usernameTextField) { (usernameTextField) in
      usernameTextField.left == usernameTextField.superview!.left + margin
      usernameTextField.top == usernameTextField.superview!.top + margin
      usernameTextField.height == 50
      usernameTextField.right == usernameTextField.superview!.right - margin
    }

    passwordTextField.placeholder = NSLocalizedString("Password")
    passwordTextField.borderStyle = UITextBorderStyle.RoundedRect
    passwordTextField.secureTextEntry = true
    view.addSubview(passwordTextField)
    layout(passwordTextField, usernameTextField) { (passwordTextField, usernameTextField) in
      passwordTextField.left == usernameTextField.left
      passwordTextField.top == usernameTextField.bottom + margin
      passwordTextField.height == usernameTextField.height
      passwordTextField.right == usernameTextField.right
    }

    signInButton.setTitle(NSLocalizedString("Sign In"), forState: UIControlState.Normal)
    signInButton.setTitleColorWithAutomaticHighlightColor(color: UIColor.whiteColor())
    signInButton.backgroundColor = UIColor.SnowballColor.blue()
    signInButton.addTarget(self, action: "signInButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(signInButton)
    layout(signInButton, passwordTextField) { (signInButton, passwordTextField) in
      signInButton.left == passwordTextField.left
      signInButton.top == passwordTextField.bottom + margin
      signInButton.height == passwordTextField.height
      signInButton.right == passwordTextField.right
    }
  }
}