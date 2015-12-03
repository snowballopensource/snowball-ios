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
    let username = usernameCell.textField.text ?? ""
    let email = emailCell.textField.text ?? ""
    let password = passwordCell.textField.text ?? ""
    return Router.SignUp(username: username, email: email, password: password)
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self

    messageLabel.text = NSLocalizedString("Ok, let's get started with creating your account.", comment: "")
    continueButton.setTitle(NSLocalizedString("sign up", comment: ""), forState: UIControlState.Normal)
  }

  // MARK: - AuthenticationViewController

  override func authenticationCompletedSuccessfully() {
    super.authenticationCompletedSuccessfully()
    Analytics.createAliasAndIdentify(User.currentUser!.id!)
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

    let index = SignUpTextFieldIndex(rawValue: indexPath.row)!
    switch(index) {
    case .Username:
      cell.descriptionLabel.text = NSLocalizedString("username", comment: "")
      cell.textField.setPlaceholder(NSLocalizedString("snowball", comment: ""), color: UIColor.SnowballColor.grayColor)
      cell.textField.text = User.currentUser?.username
      cell.textField.returnKeyType = UIReturnKeyType.Next
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