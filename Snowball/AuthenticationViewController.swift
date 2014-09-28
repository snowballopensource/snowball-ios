//
//  AuthenticationViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/27/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class AuthenticationViewController: UIViewController {
  let emailTextField = UITextField()
  let passwordTextField = UITextField()

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()
    navigationController?.navigationBar.translucent = false
    emailTextField.placeholder = NSLocalizedString("Email Address")
    emailTextField.borderStyle = UITextBorderStyle.RoundedRect
    view.addSubview(emailTextField)
    passwordTextField.placeholder = NSLocalizedString("Password")
    passwordTextField.borderStyle = UITextBorderStyle.RoundedRect
    view.addSubview(passwordTextField)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let margin: Float = 20.0
    layout(emailTextField, passwordTextField) { (emailTextField, passwordTextField) in
      emailTextField.left == emailTextField.superview!.left + margin
      emailTextField.right == emailTextField.superview!.right - margin
      emailTextField.top == emailTextField.superview!.top + margin
      emailTextField.height == 50

      passwordTextField.left == emailTextField.left
      passwordTextField.right == emailTextField.right
      passwordTextField.top == emailTextField.bottom + margin
      passwordTextField.height == emailTextField.height
    }
  }
}