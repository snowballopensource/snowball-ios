//
//  EditProfileViewController.swift
//  Snowball
//
//  Created by James Martinez on 10/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class EditProfileViewController: UIViewController {
  private let currentUser = User.currentUser!
  private let nameTextField = UITextField()
  private let usernameTextField = UITextField()
  private let emailTextField = UITextField()
  private let changePhoneNumberButton = UIButton()

  func save() {
    var newName: String?
    var newUsername: String?
    var newEmail: String?
    if nameTextField.text != currentUser.name {
      newName = nameTextField.text
    }
    if usernameTextField.text != currentUser.username {
      newUsername = usernameTextField.text
    }
    if emailTextField.text != currentUser.email {
      newEmail = emailTextField.text
    }
    if newName != nil || newUsername != nil || newEmail != nil {
      API.request(APIRoute.UpdateCurrentUser(username: newUsername, email: newEmail, name: newName)).responsePersistable(User.self) { (error) in
        if error != nil { error?.display(); return }
        self.navigationController?.popViewControllerAnimated(true)
      }
    } else {
      self.navigationController?.popViewControllerAnimated(true)
    }
  }

  func changePhoneNumber() {
    navigationController?.pushViewController(PhoneNumberChangeViewController(), animated: true)
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    title = NSLocalizedString("Edit Profile")

    let rightBarButton = UIButton(frame: CGRectMake(0, 0, 44.0, 44.0))
    rightBarButton.setTitle(NSLocalizedString("✓"), forState: UIControlState.Normal)
    rightBarButton.addTarget(self, action: "save", forControlEvents: UIControlEvents.TouchUpInside)
    rightBarButton.setTitleColorWithAutomaticHighlightColor()
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)

    nameTextField.text = currentUser.name
    nameTextField.borderStyle = UITextBorderStyle.RoundedRect
    view.addSubview(nameTextField)
    usernameTextField.text = currentUser.username
    usernameTextField.borderStyle = UITextBorderStyle.RoundedRect
    view.addSubview(usernameTextField)
    emailTextField.text = currentUser.email
    emailTextField.borderStyle = UITextBorderStyle.RoundedRect
    view.addSubview(emailTextField)
    changePhoneNumberButton.setTitle(NSLocalizedString("Change Phone Number"), forState: UIControlState.Normal)
    changePhoneNumberButton.setTitleColorWithAutomaticHighlightColor(color: UIColor.blackColor())
    changePhoneNumberButton.addTarget(self, action: "changePhoneNumber", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(changePhoneNumberButton)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let margin: Float = 20.0

    layout(nameTextField) { (nameTextField) in
      nameTextField.left == nameTextField.superview!.left + margin
      nameTextField.right == nameTextField.superview!.right - margin
      nameTextField.top == nameTextField.superview!.top + margin
      nameTextField.height == 50
    }

    layout(usernameTextField, nameTextField) { (usernameTextField, nameTextField) in
      usernameTextField.left == nameTextField.left
      usernameTextField.right == nameTextField.right
      usernameTextField.top == nameTextField.bottom + margin
      usernameTextField.height == nameTextField.height
    }

    layout(emailTextField, usernameTextField) { (emailTextField, usernameTextField) in
      emailTextField.left == usernameTextField.left
      emailTextField.right == usernameTextField.right
      emailTextField.top == usernameTextField.bottom + margin
      emailTextField.height == usernameTextField.height
    }

    layout(changePhoneNumberButton, emailTextField) { (changePhoneNumberButton, emailTextField) in
      changePhoneNumberButton.left == emailTextField.left
      changePhoneNumberButton.right == emailTextField.right
      changePhoneNumberButton.top == emailTextField.bottom + margin
      changePhoneNumberButton.height == emailTextField.height
    }
  }
}