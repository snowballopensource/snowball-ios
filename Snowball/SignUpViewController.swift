//
//  SignUpViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/7/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

// MARK: -

private enum SignUpTextFieldIndex: Int {
  case Username
  case Email
  case Password
}

// MARK: -

class SignUpViewController: AuthenticationViewController {

  // MARK: - Properties

  override var authenticationRoute: Router! {
    let usernameCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: SignUpTextFieldIndex.Username.rawValue, inSection: 0))! as! TextFieldTableViewCell
    let emailCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: SignUpTextFieldIndex.Email.rawValue, inSection: 0))! as! TextFieldTableViewCell
    let passwordCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: SignUpTextFieldIndex.Password.rawValue, inSection: 0))! as! TextFieldTableViewCell
    return Router.SignUp(username: usernameCell.textField.text, email: emailCell.textField.text, password: passwordCell.textField.text)
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self

    let messageString = NSMutableAttributedString()
    messageString.appendAttributedString(NSAttributedString(string: "Ok, let's get started with\n", attributes: [NSForegroundColorAttributeName: UIColor.blackColor()]))
    messageString.appendAttributedString(NSAttributedString(string: "creating ", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.blueColor]))
    messageString.appendAttributedString(NSAttributedString(string: "your account.", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor]))
    messageLabel.attributedText = messageString
  }

  // MARK: - AuthenticationViewController

  override func authenticationCompletedSuccessfully(user: User) {
    super.authenticationCompletedSuccessfully(user)
    Analytics.createAliasAndIdentify(user.id!)
    Analytics.track("Sign Up")
    self.navigationController?.pushViewController(PhoneNumberViewController(), animated: true)
  }
}

// MARK: -

extension SignUpViewController: UITableViewDataSource {

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 3
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(TextFieldTableViewCell),
      forIndexPath: indexPath) as! UITableViewCell
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

    let index = SignUpTextFieldIndex(rawValue: indexPath.row)!
    switch(index) {
    case .Username:
      cell.textField.setPlaceholder(NSLocalizedString("username", comment: ""), color: cell.textField.tintColor)
      cell.textField.text = User.currentUser?.username
      cell.textField.returnKeyType = UIReturnKeyType.Next
    case .Email:
      cell.textField.setPlaceholder(NSLocalizedString("email", comment: ""), color: cell.textField.tintColor)
      cell.textField.text = User.currentUser?.email
      cell.textField.keyboardType = UIKeyboardType.EmailAddress
      cell.textField.returnKeyType = UIReturnKeyType.Next
    case .Password:
      cell.textField.setPlaceholder(NSLocalizedString("password", comment: ""), color: cell.textField.tintColor)
      cell.textField.text = User.currentUser?.email
      cell.textField.secureTextEntry = true
      cell.textField.returnKeyType = UIReturnKeyType.Done
    }
  }
}