//
//  AuthenticationViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class SignUpViewController: AuthenticationViewController {}
class SignInViewController: AuthenticationViewController {}

class AuthenticationViewController: UIViewController, SnowballTopViewDelegate {

  // MARK: - Properties

  private let topBar = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: SnowballTopViewButtonType.Forward)

  private let messageLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    label.numberOfLines = 2
    return label
  }()

  private let usernameTextField: SnowballRoundedTextField = {
    let textField = SnowballRoundedTextField()
    textField.setPlaceholder(NSLocalizedString("username"), color: UIColor.SnowballColor.greenColor)
    textField.tintColor = UIColor.SnowballColor.greenColor
    textField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    textField.autocorrectionType = UITextAutocorrectionType.No
    textField.autocapitalizationType = UITextAutocapitalizationType.None
    return textField
  }()

  private let emailTextField: SnowballRoundedTextField = {
    let textField = SnowballRoundedTextField()
    textField.setPlaceholder(NSLocalizedString("email"), color: UIColor.SnowballColor.greenColor)
    textField.tintColor = UIColor.SnowballColor.greenColor
    textField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    textField.autocorrectionType = UITextAutocorrectionType.No
    textField.autocapitalizationType = UITextAutocapitalizationType.None
    textField.keyboardType = UIKeyboardType.EmailAddress
    return textField
  }()

  private let passwordTextField: SnowballRoundedTextField = {
    let textField = SnowballRoundedTextField()
    textField.setPlaceholder(NSLocalizedString("password"), color: UIColor.SnowballColor.greenColor)
    textField.tintColor = UIColor.SnowballColor.greenColor
    textField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    textField.autocorrectionType = UITextAutocorrectionType.No
    textField.autocapitalizationType = UITextAutocapitalizationType.None
    textField.secureTextEntry = true
    return textField
  }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topBar)
    topBar.setupDefaultLayout()

    let sideMargin: Float = 25

    view.addSubview(messageLabel)
    layout(messageLabel, topBar) { (messageLabel, topBar) in
      messageLabel.left == messageLabel.superview!.left + sideMargin
      messageLabel.top == topBar.bottom
      messageLabel.right == messageLabel.superview!.right - sideMargin
    }

    let betweenMargin: Float = 15
    let textFieldHeight: Float = 50

    if self.isKindOfClass(SignUpViewController) {
      let messageString = NSMutableAttributedString()
      messageString.appendAttributedString(NSAttributedString(string: "Ok, let's get started with\n", attributes: [NSForegroundColorAttributeName: UIColor.blackColor()]))
      messageString.appendAttributedString(NSAttributedString(string: "creating ", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor]))
      messageString.appendAttributedString(NSAttributedString(string: "your account.", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor]))
      messageLabel.attributedText = messageString

      view.addSubview(usernameTextField)
      layout(usernameTextField, messageLabel) { (usernameTextField, messageLabel) in
        usernameTextField.left == messageLabel.left
        usernameTextField.top == usernameTextField.superview!.top + 140
        usernameTextField.right == messageLabel.right
        usernameTextField.height == textFieldHeight
      }
    } else {
      let messageString = NSMutableAttributedString()
      messageString.appendAttributedString(NSAttributedString(string: "Ok, let's get you ", attributes: [NSForegroundColorAttributeName: UIColor.blackColor()]))
      messageString.appendAttributedString(NSAttributedString(string: "back into ", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor]))
      messageString.appendAttributedString(NSAttributedString(string: "your account.", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor]))
      messageLabel.attributedText = messageString
    }

    view.addSubview(emailTextField)
    if self.isKindOfClass(SignUpViewController) {
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
    if self.isKindOfClass(SignUpViewController) {
      usernameTextField.becomeFirstResponder()
    } else {
      emailTextField.becomeFirstResponder()
    }
  }

  // MARK: - Private

  private func validateFields() -> Bool {
    let alertController = UIAlertController(title: NSLocalizedString("Error"), message: nil, preferredStyle: UIAlertControllerStyle.Alert)
    alertController.addAction(UIAlertAction(title: NSLocalizedString("OK"), style: UIAlertActionStyle.Cancel, handler: nil))
    if countElements(usernameTextField.text) < 2 && self.isKindOfClass(SignUpViewController) {
      alertController.message = NSLocalizedString("Username needs to be longer. Please try again.")
      presentViewController(alertController, animated: true, completion: nil)
      return false
    } else if countElements(emailTextField.text) < 5 {
      alertController.message = NSLocalizedString("Email invalid. Please try again.")
      presentViewController(alertController, animated: true, completion: nil)
      return false
    } else if countElements(passwordTextField.text) < 4 {
      alertController.message = NSLocalizedString("Password needs to be longer. Please try again.")
      presentViewController(alertController, animated: true, completion: nil)
      return false
    }
    return true
  }

  private func performAuthenticationRequest() {
    var route: Router
    if self.isKindOfClass(SignUpViewController) {
      route = Router.SignUp(username: usernameTextField.text, email: emailTextField.text, password: passwordTextField.text)
    } else {
      route = Router.SignIn(email: emailTextField.text, password: passwordTextField.text)
    }
    API.request(route).responseJSON { (request, response, JSON, error) in
      if error != nil { displayAPIErrorToUser(JSON); return }
      if let userJSON: AnyObject = JSON {
        dispatch_async(dispatch_get_main_queue()) {
          let user = User.objectFromJSON(userJSON) as User?
          user?.managedObjectContext?.save(nil)
          User.currentUser = user
          if let userID = user?.id {
            if self.isKindOfClass(SignUpViewController) {
              Analytics.createAliasAndIdentify(userID)
              Analytics.track("Sign Up")
              self.navigationController?.pushViewController(PhoneNumberViewController(), animated: true)
            } else {
              Analytics.identify(userID)
              Analytics.track("Sign In")
              self.switchToNavigationController(MainNavigationController())
            }
          }
        }
      }
    }
  }
}

// MARK: -

extension AuthenticationViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }

  func snowballTopViewRightButtonTapped() {
    if validateFields() {
      performAuthenticationRequest()
    }
  }
}