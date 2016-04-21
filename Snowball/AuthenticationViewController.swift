//
//  AuthenticationViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/25/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import UIKit

class AuthenticationViewController: UIViewController {

  // MARK: Properties

  let topLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.text = NSLocalizedString("Welcome back!\nLogin to your account.", comment: "")
    label.font = UIFont.SnowballFont.regularFont.fontWithSize(20)
    return label
  }()

  let emailTextField: FormTextField = {
    let textField = FormTextField()
    textField.hint = NSLocalizedString("Email", comment: "")
    textField.placeholder = NSLocalizedString("Your email address", comment: "")
    textField.autocapitalizationType = .None
    textField.autocorrectionType = .No
    textField.spellCheckingType = .No
    textField.keyboardType = .EmailAddress
    textField.returnKeyType = .Next
    return textField
  }()

  let passwordTextField: FormTextField = {
    let textField = FormTextField()
    textField.hint = NSLocalizedString("Password", comment: "")
    textField.placeholder = NSLocalizedString("Your password", comment: "")
    textField.autocapitalizationType = .None
    textField.autocorrectionType = .No
    textField.spellCheckingType = .No
    textField.returnKeyType = .Go
    textField.secureTextEntry = true
    return textField
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
      topLabel.left == topLabel.superview!.left + FormTextField.defaultSideMargin
      topLabel.top == topLabel.superview!.top + 50
      topLabel.width == topLabel.superview!.width * 0.70
    }

    view.addSubview(emailTextField)
    constrain(emailTextField, topLabel) { emailTextField, topLabel in
      emailTextField.left == emailTextField.superview!.left + FormTextField.defaultSideMargin
      emailTextField.top == topLabel.bottom + 40
      emailTextField.right == emailTextField.superview!.right - FormTextField.defaultSideMargin
      emailTextField.height == FormTextField.defaultHeight
    }
    emailTextField.delegate = self

    view.addSubview(passwordTextField)
    constrain(passwordTextField, emailTextField) { passwordTextField, emailTextField in
      passwordTextField.left == emailTextField.left
      passwordTextField.top == emailTextField.bottom + FormTextField.defaultSpaceBetween
      passwordTextField.right == emailTextField.right
      passwordTextField.height == emailTextField.height
    }
    passwordTextField.delegate = self

    FormTextField.linkFormTextFieldsHintSizing([emailTextField, passwordTextField])

    view.addSubview(submitButton)
    constrain(submitButton, passwordTextField) { submitButton, passwordTextField in
      submitButton.left == passwordTextField.left
      submitButton.top == passwordTextField.bottom + 40
      submitButton.right == passwordTextField.right
      submitButton.height == SnowballActionButton.defaultHeight
    }
    submitButton.addTarget(self, action: #selector(AuthenticationViewController.submitButtonPressed), forControlEvents: .TouchUpInside)
  }

  // MARK: Actions

  @objc private func submitButtonPressed() {
    signIn()
  }

  // MARK: Private

  private func signIn() {
    guard let email = emailTextField.text, let password = passwordTextField.text else { return }
    SnowballAPI.requestObject(SnowballRoute.SignIn(email: email, password: password)) { (response: ObjectResponse<User>) in
      switch response {
      case .Success(let user):
        User.currentUser = user
        // TODO: Analytics
        // TODO: Push notifications
        self.dismissViewControllerAnimated(true, completion: nil)
      case .Failure(let error): error.displayToUserIfAppropriateFromViewController(self)
      }
    }
  }
}

extension AuthenticationViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    } else if textField == passwordTextField {
      signIn()
    }
    return true
  }
}