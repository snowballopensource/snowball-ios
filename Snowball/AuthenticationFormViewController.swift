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
  case signIn
  case signUp
}

class AuthenticationFormViewController: UIViewController {

  // MARK: Properties

  private let type: AuthenticationFormViewControllerType

  let topLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 2
    label.font = UIFont.SnowballFont.regularFont.withSize(20)
    return label
  }()

  let usernameTextField: FormTextField = {
    let textField = FormTextField()
    textField.hint = NSLocalizedString("Username", comment: "")
    textField.placeholder = NSLocalizedString("Your username", comment: "")
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.spellCheckingType = .no
    textField.returnKeyType = .next
    return textField
  }()

  let emailTextField: FormTextField = {
    let textField = FormTextField()
    textField.hint = NSLocalizedString("Email", comment: "")
    textField.placeholder = NSLocalizedString("Your email address", comment: "")
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.spellCheckingType = .no
    textField.keyboardType = .emailAddress
    textField.returnKeyType = .next
    return textField
  }()

  let passwordTextField: FormTextField = {
    let textField = FormTextField()
    textField.hint = NSLocalizedString("Password", comment: "")
    textField.placeholder = NSLocalizedString("Your password", comment: "")
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.spellCheckingType = .no
    textField.returnKeyType = .go
    textField.isSecureTextEntry = true
    return textField
  }()

  let submitButton = SnowballActionButton()

  // MARK: Initializer

  init(type: AuthenticationFormViewControllerType) {
    self.type = type
    super.init(nibName: nil, bundle: nil)

    if type == .signUp {
      topLabel.text = NSLocalizedString("Ok, let's get started with\ncreating your account.", comment: "")
      submitButton.setTitle(NSLocalizedString("sign up", comment: ""), for: UIControlState())
    } else {
      topLabel.text = NSLocalizedString("Welcome back!\nLogin to your account.", comment: "")
      submitButton.setTitle(NSLocalizedString("log in", comment: ""), for: UIControlState())
    }
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-back-black"), style: .plain, target: self, action: #selector(AuthenticationFormViewController.leftBarButtonItemPressed))

    view.backgroundColor = UIColor.white

    view.addSubview(topLabel)
    constrain(topLabel) { topLabel in
      topLabel.left == topLabel.superview!.left + FormTextField.defaultSideMargin
      topLabel.top == topLabel.superview!.top + 70
      topLabel.width == topLabel.superview!.width * 0.70
    }

    if type == .signUp {
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
    submitButton.addTarget(self, action: #selector(AuthenticationFormViewController.submitButtonPressed), for: .touchUpInside)
  }

  // MARK: Actions

  @objc private func submitButtonPressed() {
    authenticate()
  }

  // MARK: Private

  fileprivate func authenticate() {
    var route: SnowballRoute
    guard let email = emailTextField.text, let password = passwordTextField.text else { return }
    if type == .signUp {
      guard let username = usernameTextField.text else { return }
      route = SnowballRoute.signUp(username: username, email: email, password: password)
    } else {
      route = SnowballRoute.signIn(email: email, password: password)
    }

    SnowballAPI.requestObject(route) { (response: ObjectResponse<User>) in
      switch response {
      case .success(let user):
        User.currentUser = user
        if let userID = User.currentUser?.id {
          Analytics.identify(userID)
        }
        if self.type == .signUp {
          Analytics.track("Sign Up")
        } else {
          Analytics.track("Sign In")
        }
        // TODO: Push notifications
        self.dismiss(animated: true, completion: nil)
      case .failure(let error): error.displayToUserIfAppropriateFromViewController(self)
      }
    }
  }

  @objc private func leftBarButtonItemPressed() {
    navigationController?.popViewController(animated: true)
  }
}

extension AuthenticationFormViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
