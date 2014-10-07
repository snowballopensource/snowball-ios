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
  let nameTextField = UITextField()
  let usernameTextField = UITextField()
  let emailTextField = UITextField()

  func save() {
    // TODO: push the changes to the API
    navigationController?.popViewControllerAnimated(true)
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    let rightBarButton = UIButton(frame: CGRectMake(0, 0, 44.0, 44.0))
    rightBarButton.setTitle(NSLocalizedString("✓"), forState: UIControlState.Normal)
    rightBarButton.addTarget(self, action: "save", forControlEvents: UIControlEvents.TouchUpInside)
    rightBarButton.setTitleColorWithAutomaticHighlightColor()
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)

    let currentUser = User.currentUser!

    nameTextField.text = currentUser.name
    nameTextField.borderStyle = UITextBorderStyle.RoundedRect
    view.addSubview(nameTextField)
    usernameTextField.text = currentUser.username
    usernameTextField.borderStyle = UITextBorderStyle.RoundedRect
    view.addSubview(usernameTextField)
    emailTextField.text = currentUser.email
    emailTextField.borderStyle = UITextBorderStyle.RoundedRect
    view.addSubview(emailTextField)
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
  }
}