//
//  AuthenticationFormViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/25/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import UIKit

enum AuthenticationFormViewControllerType {
  case SignIn
  case SignUp
}

class AuthenticationFormViewController: UIViewController {

  // MARK: Properties

  private let type: AuthenticationFormViewControllerType

  let topLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.font = UIFont.SnowballFont.regularFont.fontWithSize(20)
    return label
  }()

  let usernameTextField: FormTextField = {
    let textField = FormTextField()
    textField.hint = NSLocalizedString("Username", comment: "")
    textField.placeholder = NSLocalizedString("Your username", comment: "")
    textField.autocapitalizationType = .None
    textField.autocorrectionType = .No
    textField.spellCheckingType = .No
    textField.returnKeyType = .Next
    return textField
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

  let submitButton = SnowballActionButton()

  // MARK: Initializer

  init(type: AuthenticationFormViewControllerType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)

    if type == .SignUp {
      topLabel.text = NSLocalizedString("Ok, let's get started with\ncreating your account.", comment: "")
      submitButton.setTitle(NSLocalizedString("sign up", comment: ""), forState: .Normal)
    } else {
      topLabel.text = NSLocalizedString("Welcome back!\nLogin to your account.", comment: "")
      submitButton.setTitle(NSLocalizedString("log in", comment: ""), forState: .Normal)
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-back-black"), style: .Plain, target: self, action: #selector(AuthenticationFormViewController.leftBarButtonItemPressed))

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topLabel)
    constrain(topLabel) { topLabel in
      topLabel.left == topLabel.superview!.left + FormTextField.defaultSideMargin
      topLabel.top == topLabel.superview!.top + 70
      topLabel.width == topLabel.superview!.width * 0.70
    }

    if type == .SignUp {
      view.addSubview(usernameTextField)
      constrain(usernameTextField, topLabel) { usernameTextField, topLabel in
        usernameTextField.left == usernameTextField.superview!.left + FormTextField.defaultSideMargin
        usernameTextField.top == topLabel.bottom + 40
        usernameTextField.right == usernameTextField.superview!.right - FormTextField.defaultSideMargin
        usernameTextField.height == FormTextField.defaultHeight
      }

      view.addSubview(emailTextField)
      constrain(emailTextField, usernameTextField) { emailTextField, usernameTextField in
        emailTextField.left == usernameTextField.left
        emailTextField.top == usernameTextField.bottom + FormTextField.defaultSpaceBetween
        emailTextField.right == usernameTextField.right
        emailTextField.height == usernameTextField.height
      }
    } else {
      view.addSubview(emailTextField)
      constrain(emailTextField, topLabel) { emailTextField, topLabel in
        emailTextField.left == emailTextField.superview!.left + FormTextField.defaultSideMargin
        emailTextField.top == topLabel.bottom + 40
        emailTextField.right == emailTextField.superview!.right - FormTextField.defaultSideMargin
        emailTextField.height == FormTextField.defaultHeight
      }
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

    FormTextField.linkFormTextFieldsHintSizing([usernameTextField, emailTextField, passwordTextField])

    view.addSubview(submitButton)
    constrain(submitButton, passwordTextField) { submitButton, passwordTextField in
      submitButton.left == passwordTextField.left
      submitButton.top == passwordTextField.bottom + 40
      submitButton.right == passwordTextField.right
      submitButton.height == SnowballActionButton.defaultHeight
    }
    submitButton.addTarget(self, action: #selector(AuthenticationFormViewController.submitButtonPressed), forControlEvents: .TouchUpInside)
  }

  // MARK: Actions

  @objc private func submitButtonPressed() {
    authenticate()
  }

  // MARK: Private

  private func authenticate() {
    var route: SnowballRoute
    guard let email = emailTextField.text, let password = passwordTextField.text else { return }
    if type == .SignUp {
      guard let username = usernameTextField.text else { return }
      route = SnowballRoute.SignUp(username: username, email: email, password: password)
    } else {
      route = SnowballRoute.SignIn(email: email, password: password)
    }

    SnowballAPI.requestObject(route) { (response: ObjectResponse<User>) in
      switch response {
      case .Success(let user):
        User.currentUser = user
        if let userID = User.currentUser?.id {
          Analytics.identify(userID)
        }
        if self.type == .SignUp {
          Analytics.track("Sign Up")
        } else {
          Analytics.track("Sign In")
        }
        // TODO: Push notifications
        self.dismissViewControllerAnimated(true, completion: nil)
      case .Failure(let error): error.displayToUserIfAppropriateFromViewController(self)
      }
    }
  }

  @objc private func leftBarButtonItemPressed() {
    navigationController?.popViewControllerAnimated(true)
  }
}

extension AuthenticationFormViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == usernameTextField {
      emailTextField.becomeFirstResponder()
    } else if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    } else if textField == passwordTextField {
      authenticate()
    }
    return true
  }
}