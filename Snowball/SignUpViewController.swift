//
//  SignUpViewController.swift
//  Snowball
//
//  Created by James Martinez on 11/12/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class SignUpViewController: UIViewController {
  let emailTextField = UITextField()
  let usernameTextField = UITextField()
  let passwordTextField = UITextField()
  let signUpButton = UIButton()

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    title = NSLocalizedString("Sign Up")

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

    emailTextField.placeholder = NSLocalizedString("Email")
    emailTextField.borderStyle = UITextBorderStyle.RoundedRect
    emailTextField.keyboardType = UIKeyboardType.EmailAddress
    view.addSubview(emailTextField)
    layout(emailTextField, usernameTextField) { (emailTextField, usernameTextField) in
      emailTextField.left == usernameTextField.left
      emailTextField.top == usernameTextField.bottom + margin
      emailTextField.height == usernameTextField.height
      emailTextField.right == usernameTextField.right
    }

    passwordTextField.placeholder = NSLocalizedString("Password")
    passwordTextField.borderStyle = UITextBorderStyle.RoundedRect
    passwordTextField.secureTextEntry = true
    view.addSubview(passwordTextField)
    layout(passwordTextField, emailTextField) { (passwordTextField, emailTextField) in
      passwordTextField.left == emailTextField.left
      passwordTextField.top == emailTextField.bottom + margin
      passwordTextField.height == emailTextField.height
      passwordTextField.right == emailTextField.right
    }

    signUpButton.setTitle(NSLocalizedString("Sign Up"), forState: UIControlState.Normal)
    signUpButton.setTitleColorWithAutomaticHighlightColor(color: UIColor.whiteColor())
    signUpButton.backgroundColor = UIColor.SnowballColor.blue()
    signUpButton.addTarget(self, action: "signUpButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(signUpButton)
    layout(signUpButton, passwordTextField) { (signUpButton, passwordTextField) in
      signUpButton.left == passwordTextField.left
      signUpButton.top == passwordTextField.bottom + margin
      signUpButton.height == passwordTextField.height
      signUpButton.right == passwordTextField.right
    }
  }
}