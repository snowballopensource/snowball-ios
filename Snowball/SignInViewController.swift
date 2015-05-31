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
    return Router.SignIn(email: emailCell.textField.text, password: passwordCell.textField.text)
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.dataSource = self

    let messageString = NSMutableAttributedString()
    messageString.appendAttributedString(NSAttributedString(string: "Ok, let's get you ", attributes: [NSForegroundColorAttributeName: UIColor.blackColor()]))
    messageString.appendAttributedString(NSAttributedString(string: "back into ", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor]))
    messageString.appendAttributedString(NSAttributedString(string: "your account.", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor]))
    messageLabel.attributedText = messageString
  }

  // MARK: - AuthenticationViewController

  override func authenticationCompletedSuccessfully(user: User) {
    super.authenticationCompletedSuccessfully(user)
    Analytics.identify(user.id!)
    Analytics.track("Sign In")
    self.switchToNavigationController(MainNavigationController())
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

    let index = SignInTextFieldIndex(rawValue: indexPath.row)!
    switch(index) {
    case .Email:
      cell.textField.setPlaceholder(NSLocalizedString("email"), color: cell.textField.tintColor)
      cell.textField.text = User.currentUser?.email
      cell.textField.keyboardType = UIKeyboardType.EmailAddress
    case .Password:
      cell.textField.setPlaceholder(NSLocalizedString("password"), color: cell.textField.tintColor)
      cell.textField.text = User.currentUser?.email
      cell.textField.secureTextEntry = true
    }
  }
}