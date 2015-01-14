//
//  OnboardingAuthenticationViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class OnboardingAuthenticationViewController: UIViewController, OnboardingTopViewDelegate {
  let topBar = OnboardingTopView()
  let messageLabel = UILabel()
  let usernameTextField = UITextField()
  let emailTextField = UITextField()
  let passwordTextField = UITextField()
  var showUsernameTextField = false

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    topBar.setPage(0)
    view.addSubview(topBar)
    layout(topBar) { (topBar) in
      topBar.left == topBar.superview!.left
      topBar.top == topBar.superview!.top
      topBar.right == topBar.superview!.right
      topBar.height == 65
    }

    let sideMargin: Float = 25

    messageLabel.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    messageLabel.numberOfLines = 2
    view.addSubview(messageLabel)
    layout(messageLabel) { (messageLabel) in
      messageLabel.left == messageLabel.superview!.left + sideMargin
      messageLabel.top == messageLabel.superview!.top + 65
      messageLabel.right == messageLabel.superview!.right - sideMargin
    }

    let betweenMargin: Float = 15
    let textFieldHeight: Float = 50

    if showUsernameTextField {
      usernameTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("username"), attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
      usernameTextField.textColor = UIColor.SnowballColor.greenColor
      usernameTextField.tintColor = UIColor.SnowballColor.greenColor
      usernameTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
      usernameTextField.alignLeft()
      usernameTextField.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
      usernameTextField.autocorrectionType = UITextAutocorrectionType.No
      usernameTextField.autocapitalizationType = UITextAutocapitalizationType.None
      view.addSubview(usernameTextField)
      layout(usernameTextField, messageLabel) { (usernameTextField, messageLabel) in
        usernameTextField.left == messageLabel.left
        usernameTextField.top == usernameTextField.superview!.top + 140
        usernameTextField.right == messageLabel.right
        usernameTextField.height == textFieldHeight
      }
    }

    emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("email"), attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
    emailTextField.textColor = UIColor.SnowballColor.greenColor
    emailTextField.tintColor = UIColor.SnowballColor.greenColor
    emailTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    emailTextField.alignLeft()
    emailTextField.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
    emailTextField.autocorrectionType = UITextAutocorrectionType.No
    emailTextField.autocapitalizationType = UITextAutocapitalizationType.None
    emailTextField.keyboardType = UIKeyboardType.EmailAddress
    view.addSubview(emailTextField)
    if showUsernameTextField {
      layout(emailTextField, usernameTextField) { (emailTextField, usernameTextField) in
        emailTextField.left == usernameTextField.left
        emailTextField.top == usernameTextField.bottom + betweenMargin
        emailTextField.right == usernameTextField.right
        emailTextField.height == textFieldHeight
      }
    } else {
      layout(emailTextField, messageLabel) { (emailTextField, messageLabel) in
        emailTextField.left == messageLabel.left
        emailTextField.top == emailTextField.superview!.top + 140
        emailTextField.right == messageLabel.right
        emailTextField.height == textFieldHeight
      }
    }


    passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("password"), attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
    passwordTextField.textColor = UIColor.SnowballColor.greenColor
    passwordTextField.tintColor = UIColor.SnowballColor.greenColor
    passwordTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    passwordTextField.alignLeft()
    passwordTextField.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
    passwordTextField.autocorrectionType = UITextAutocorrectionType.No
    passwordTextField.autocapitalizationType = UITextAutocapitalizationType.None
    passwordTextField.secureTextEntry = true
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
    if showUsernameTextField {
      usernameTextField.becomeFirstResponder()
    } else {
      emailTextField.becomeFirstResponder()
    }
  }

  // MARK: - OnboardingTopViewDelegate

  func onboardingTopViewBackButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }

  func onboardingTopViewForwardButtonTapped() {
    goForward()
  }

  // MARK: - OnboardingAuthenticationViewController

  func validateFields() -> Bool {
    if countElements(usernameTextField.text) < 2 {
      if showUsernameTextField {
        return false
      }
    } else if countElements(emailTextField.text) < 5 {
      return false
    } else if countElements(passwordTextField.text) < 4 {
      return false
    }
    return true
  }

  func goForward() {
    assert(false, "Implement `goForward` in subclass of OnboardingAuthenticationViewController")
  }

}