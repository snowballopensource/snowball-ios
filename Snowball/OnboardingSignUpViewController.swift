//
//  OnboardingSignUpViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class OnboardingSignUpViewController: UIViewController {
  let topBar = UIView()
  let messageLabel = UILabel()
  let usernameTextField = UITextField()
  let emailTextField = UITextField()
  let passwordTextField = UITextField()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topBar)
    layout(topBar) { (topBar) in
      topBar.left == topBar.superview!.left
      topBar.top == topBar.superview!.top
      topBar.right == topBar.superview!.right
      topBar.height == 65
    }

    let sideMargin: Float = 25

    messageLabel.text = NSLocalizedString("Ok, let's get started with creating your account.")
    messageLabel.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    messageLabel.numberOfLines = 2
    view.addSubview(messageLabel)
    layout(messageLabel, topBar) { (messageLabel, topBar) in
      messageLabel.left == messageLabel.superview!.left + sideMargin
      messageLabel.top == topBar.bottom
      messageLabel.right == messageLabel.superview!.right - sideMargin
    }

    let betweenMargin: Float = 15
    let textFieldHeight: Float = 50

    usernameTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("username"), attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
    usernameTextField.textColor = UIColor.SnowballColor.greenColor
    usernameTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    usernameTextField.alignLeft()
    usernameTextField.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
    view.addSubview(usernameTextField)
    layout(usernameTextField, messageLabel) { (usernameTextField, messageLabel) in
      usernameTextField.left == messageLabel.left
      usernameTextField.top == messageLabel.bottom + betweenMargin
      usernameTextField.right == messageLabel.right
      usernameTextField.height == textFieldHeight
    }

    emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("email"), attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
    emailTextField.textColor = UIColor.SnowballColor.greenColor
    emailTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    emailTextField.alignLeft()
    emailTextField.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
    view.addSubview(emailTextField)
    layout(emailTextField, usernameTextField) { (emailTextField, usernameTextField) in
      emailTextField.left == usernameTextField.left
      emailTextField.top == usernameTextField.bottom + betweenMargin
      emailTextField.right == usernameTextField.right
      emailTextField.height == textFieldHeight
    }

    passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("password"), attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
    passwordTextField.textColor = UIColor.SnowballColor.greenColor
    passwordTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    passwordTextField.alignLeft()
    passwordTextField.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
    view.addSubview(passwordTextField)
    layout(passwordTextField, emailTextField) { (passwordTextField, emailTextField) in
      passwordTextField.left == emailTextField.left
      passwordTextField.top == emailTextField.bottom + betweenMargin
      passwordTextField.right == emailTextField.right
      passwordTextField.height == textFieldHeight
    }
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    usernameTextField.becomeFirstResponder()
  }
}