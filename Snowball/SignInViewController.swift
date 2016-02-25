//
//  SignInViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/25/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import UIKit

class SignInViewController: UIViewController {

  // MARK: Properties

  let topLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.text = NSLocalizedString("Welcome back!\nLogin to your account.", comment: "")
    label.font = UIFont.SnowballFont.regularFont.fontWithSize(20)
    return label
  }()

  let emailTextField: TextFieldContainerView = {
    let textFieldContainer = TextFieldContainerView()
    textFieldContainer.configureText(hint: NSLocalizedString("Email", comment: ""), placeholder: NSLocalizedString("Your email address", comment: ""))
    textFieldContainer.textField.autocapitalizationType = .None
    textFieldContainer.textField.autocorrectionType = .No
    textFieldContainer.textField.spellCheckingType = .No
    textFieldContainer.textField.keyboardType = .EmailAddress
    textFieldContainer.textField.returnKeyType = .Next
    return textFieldContainer
  }()

  let passwordTextField: TextFieldContainerView = {
    let textFieldContainer = TextFieldContainerView()
    textFieldContainer.configureText(hint: NSLocalizedString("Password", comment: ""), placeholder: NSLocalizedString("Your password", comment: ""))
    textFieldContainer.textField.autocapitalizationType = .None
    textFieldContainer.textField.autocorrectionType = .No
    textFieldContainer.textField.spellCheckingType = .No
    textFieldContainer.textField.returnKeyType = .Go
    textFieldContainer.textField.secureTextEntry = true
    return textFieldContainer
  }()

  let submitButton: SnowballActionButton = {
    let button = SnowballActionButton()
    button.setTitle(NSLocalizedString("log in", comment: ""), forState: .Normal)
    return button
  }()

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topLabel)
    constrain(topLabel) { topLabel in
      topLabel.left == topLabel.superview!.left + TextFieldContainerView.defaultSideMargin
      topLabel.top == topLabel.superview!.top + 50
      topLabel.width == topLabel.superview!.width * 0.70
    }

    view.addSubview(emailTextField)
    constrain(emailTextField, topLabel) { emailTextField, topLabel in
      emailTextField.left == emailTextField.superview!.left + TextFieldContainerView.defaultSideMargin
      emailTextField.top == topLabel.bottom + 40
      emailTextField.right == emailTextField.superview!.right - TextFieldContainerView.defaultSideMargin
      emailTextField.height == TextFieldContainerView.defaultHeight
    }

    view.addSubview(passwordTextField)
    constrain(passwordTextField, emailTextField) { passwordTextField, emailTextField in
      passwordTextField.left == emailTextField.left
      passwordTextField.top == emailTextField.bottom + TextFieldContainerView.defaultSpaceBetween
      passwordTextField.right == emailTextField.right
      passwordTextField.height == emailTextField.height
    }
    passwordTextField.linkSizingWithTextFieldContainerView(emailTextField)

    view.addSubview(submitButton)
    constrain(submitButton, passwordTextField) { submitButton, passwordTextField in
      submitButton.left == passwordTextField.left
      submitButton.top == passwordTextField.bottom + 40
      submitButton.right == passwordTextField.right
      submitButton.height == SnowballActionButton.defaultHeight
    }
  }
}