//
//  SignInViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/7/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

private enum SignInTextFieldIndex: Int {
  case Email
  case Password
}

// MARK: -

class SignInViewController: AuthenticationViewController {

  // MARK: - Properties

  override var authenticationRoute: Router! {
    let emailCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: SignInTextFieldIndex.Email.rawValue, inSection: 0))! as! TextFieldTableViewCell
    let passwordCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: SignInTextFieldIndex.Password.rawValue, inSection: 0))! as! TextFieldTableViewCell
    let email = emailCell.textField.text ?? ""
    let password = passwordCell.textField.text ?? ""
    return Router.SignIn(email: email, password: password)
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self

    messageLabel.text = NSLocalizedString("Welcome back! \nLogin to your account.", comment: "")
    continueButton.setTitle(NSLocalizedString("sign in", comment: ""), forState: UIControlState.Normal)
  }

  // MARK: - AuthenticationViewController

  override func authenticationCompletedSuccessfully() {
    super.authenticationCompletedSuccessfully()
    Analytics.identify(User.currentUser!.id!)
    Analytics.track("Sign In")
    PushManager.registerForPushNotifications()
    dismissViewControllerAnimated(true, completion: nil)
  }
}

// MARK: -

extension SignInViewController: UITableViewDataSource {

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 2
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TextFieldTableViewCell),
      forIndexPath: indexPath) 
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  // MARK: - Private

  private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cell = cell as! TextFieldTableViewCell

    cell.textField.autocorrectionType = UITextAutocorrectionType.No
    cell.textField.autocapitalizationType = UITextAutocapitalizationType.None
    cell.textField.keyboardType = UIKeyboardType.Default
    cell.textField.secureTextEntry = false
    cell.textField.delegate = self

    let index = SignInTextFieldIndex(rawValue: indexPath.row)!
    switch(index) {
    case .Email:
      cell.descriptionLabel.text = NSLocalizedString("email", comment: "")
      cell.textField.setPlaceholder(NSLocalizedString("hello@snowball.is", comment: ""), color: UIColor.SnowballColor.grayColor)
      cell.textField.text = User.currentUser?.email
      cell.textField.keyboardType = UIKeyboardType.EmailAddress
      cell.textField.returnKeyType = UIReturnKeyType.Next
    case .Password:
      cell.descriptionLabel.text = NSLocalizedString("password", comment: "")
      cell.textField.setPlaceholder(NSLocalizedString("password", comment: ""), color: UIColor.SnowballColor.grayColor)
      cell.textField.text = User.currentUser?.email
      cell.textField.secureTextEntry = true
      cell.textField.returnKeyType = UIReturnKeyType.Done
    }
  }
}