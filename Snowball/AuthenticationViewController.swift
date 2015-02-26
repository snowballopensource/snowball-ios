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
  let topBar = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: SnowballTopViewButtonType.Forward)
  let messageLabel = UILabel()
  let usernameTextField = UITextField()
  let emailTextField = UITextField()
  let passwordTextField = UITextField()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topBar)
    topBar.setupDefaultLayout()

    let sideMargin: Float = 25

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

    if self.isKindOfClass(SignUpViewController) {
      let messageStringOne = NSAttributedString(string: "Ok, let's get started with\n", attributes: [NSForegroundColorAttributeName: UIColor.blackColor()])
      let messageStringTwo = NSAttributedString(string: "creating ", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
      let messageStringThree = NSAttributedString(string: "your account.", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor])
      let messageString = NSMutableAttributedString(attributedString: messageStringOne)
      messageString.appendAttributedString(messageStringTwo)
      messageString.appendAttributedString(messageStringThree)
      messageLabel.attributedText = messageString

      usernameTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("username"), attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
      usernameTextField.textColor = UIColor.SnowballColor.greenColor
      usernameTextField.tintColor = UIColor.SnowballColor.greenColor
      usernameTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
      usernameTextField.alignLeft(insetWidth: 20)
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
    } else {
      let messageStringOne = NSAttributedString(string: "Ok, let's get you ", attributes: [NSForegroundColorAttributeName: UIColor.blackColor()])
      let messageStringTwo = NSAttributedString(string: "back into\n", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
      let messageStringThree = NSAttributedString(string: "your account.", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor])
      let messageString = NSMutableAttributedString(attributedString: messageStringOne)
      messageString.appendAttributedString(messageStringTwo)
      messageString.appendAttributedString(messageStringThree)
      messageLabel.attributedText = messageString
    }

    emailTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("email"), attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
    emailTextField.textColor = UIColor.SnowballColor.greenColor
    emailTextField.tintColor = UIColor.SnowballColor.greenColor
    emailTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    emailTextField.alignLeft(insetWidth: 20)
    emailTextField.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
    emailTextField.autocorrectionType = UITextAutocorrectionType.No
    emailTextField.autocapitalizationType = UITextAutocapitalizationType.None
    emailTextField.keyboardType = UIKeyboardType.EmailAddress
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


    passwordTextField.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("password"), attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
    passwordTextField.textColor = UIColor.SnowballColor.greenColor
    passwordTextField.tintColor = UIColor.SnowballColor.greenColor
    passwordTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    passwordTextField.alignLeft(insetWidth: 20)
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
    if self.isKindOfClass(SignUpViewController) {
      usernameTextField.becomeFirstResponder()
    } else {
      emailTextField.becomeFirstResponder()
    }
  }

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }

  func snowballTopViewRightButtonTapped() {
    if validateFields() {
      performAuthenticationRequest()
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
              Analytics.createAlias(userID)
              Analytics.track("Sign Up")
              self.navigationController?.pushViewController(PhoneNumberViewController(), animated: true)
            } else {
              Analytics.track("Sign In")
              AppDelegate.switchToNavigationController(MainNavigationController())
            }
            Analytics.identify(userID)
          }
        }
      }
    }
  }
}