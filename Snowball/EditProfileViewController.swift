//
//  EditProfileViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/2/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation

class EditProfileViewController: UIViewController, SnowballTopViewDelegate {
  private let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: nil, title: "Edit Profile")
  private let avatarLabel: UILabel = {
    let avatarLabel = UILabel()
    avatarLabel.font = UIFont(name: UIFont.SnowballFont.bold, size: 11)
    avatarLabel.text = NSLocalizedString("AVATAR")
    return avatarLabel
  }()
  private let avatarImageView: UserAvatarImageView = {
    let avatarImageView = UserAvatarImageView()
    avatarImageView.backgroundColor = UIColor.SnowballColor.greenColor
    return avatarImageView
  }()
  private let usernameLabel: UILabel = {
    let usernameLabel = UILabel()
    usernameLabel.font = UIFont(name: UIFont.SnowballFont.bold, size: 11)
    usernameLabel.text = NSLocalizedString("USERNAME")
    return usernameLabel
  }()
  private let usernameTextField: UITextField = {
    let usernameTextField = UITextField()
    usernameTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 26)
    usernameTextField.textColor = UIColor.SnowballColor.greenColor
    usernameTextField.text = User.currentUser?.username
    usernameTextField.alignLeft(insetWidth: 0)
    usernameTextField.autocorrectionType = UITextAutocorrectionType.No
    usernameTextField.autocapitalizationType = UITextAutocapitalizationType.None
    return usernameTextField
  }()
  private let phoneLabel: UILabel = {
    let phoneLabel = UILabel()
    phoneLabel.font = UIFont(name: UIFont.SnowballFont.bold, size: 11)
    phoneLabel.text = NSLocalizedString("PHONE")
    return phoneLabel
  }()
  private let phoneTextField: UITextField = {
    let phoneTextField = UITextField()
    phoneTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 26)
    phoneTextField.textColor = UIColor.SnowballColor.greenColor
    phoneTextField.text = "14151234567(t)"
    phoneTextField.alignLeft(insetWidth: 0)
    phoneTextField.autocorrectionType = UITextAutocorrectionType.No
    phoneTextField.autocapitalizationType = UITextAutocapitalizationType.None
    return phoneTextField
  }()
  private let emailLabel: UILabel = {
    let emailLabel = UILabel()
    emailLabel.font = UIFont(name: UIFont.SnowballFont.bold, size: 11)
    emailLabel.text = NSLocalizedString("EMAIL")
    return emailLabel
  }()
  private let emailTextField: UITextField = {
    let emailTextField = UITextField()
    emailTextField.font = UIFont(name: UIFont.SnowballFont.regular, size: 26)
    emailTextField.textColor = UIColor.SnowballColor.greenColor
    emailTextField.text = "wrong@gmail.com(t)"
    emailTextField.alignLeft(insetWidth: 0)
    emailTextField.autocorrectionType = UITextAutocorrectionType.No
    emailTextField.autocapitalizationType = UITextAutocapitalizationType.None
    return emailTextField
  }()
  private let logOutButton: UIButton = {
    let logOutButton = UIButton()
    logOutButton.setTitle(NSLocalizedString("log out"), forState: UIControlState.Normal)
    logOutButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
    logOutButton.titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    logOutButton.alignLeft(insetWidth: 20)
    logOutButton.showSnowballStyleBorderWithColor(UIColor.redColor())
    return logOutButton
  }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(topView)
    topView.setupDefaultLayout()

    let margin: Float = 20
    let textFieldHeight: Float = 35
    let afterLabelSpacing: Float = 7
    let afterTextFieldSpacing: Float = 20

    view.addSubview(avatarLabel)
    layout(avatarLabel, topView) { (avatarLabel, topView) in
      avatarLabel.left == avatarLabel.superview!.left + margin
      avatarLabel.top == topView.bottom + 5
    }

    view.addSubview(avatarImageView)
    layout(avatarImageView, avatarLabel) { (avatarImageView, avatarLabel) in
      avatarImageView.top == avatarLabel.bottom + afterLabelSpacing
      avatarImageView.centerX == avatarImageView.superview!.centerX
      let diameter: Float = 110
      avatarImageView.width == diameter
      avatarImageView.height == diameter
    }

    view.addSubview(usernameLabel)
    layout(usernameLabel, avatarImageView) { (usernameLabel, avatarImageView) in
      usernameLabel.left == usernameLabel.superview!.left + margin
      usernameLabel.top == avatarImageView.bottom + afterTextFieldSpacing
    }

    view.addSubview(usernameTextField)
    layout(usernameTextField, usernameLabel) { (usernameTextField, usernameLabel) in
      usernameTextField.left == usernameTextField.superview!.left + margin
      usernameTextField.top == usernameLabel.bottom + afterLabelSpacing
      usernameTextField.right == usernameTextField.superview!.right - margin
      usernameTextField.height == textFieldHeight
    }

    view.addSubview(phoneLabel)
    layout(phoneLabel, usernameTextField) { (phoneLabel, usernameTextField) in
      phoneLabel.left == phoneLabel.superview!.left + margin
      phoneLabel.top == usernameTextField.bottom + afterTextFieldSpacing
    }

    view.addSubview(phoneTextField)
    layout(phoneTextField, phoneLabel) { (phoneTextField, phoneLabel) in
      phoneTextField.left == phoneTextField.superview!.left + margin
      phoneTextField.top == phoneLabel.bottom + afterLabelSpacing
      phoneTextField.right == phoneTextField.superview!.right - margin
      phoneTextField.height == textFieldHeight
    }

    view.addSubview(emailLabel)
    layout(emailLabel, phoneTextField) { (emailLabel, phoneTextField) in
      emailLabel.left == emailLabel.superview!.left + margin
      emailLabel.top == phoneTextField.bottom + afterTextFieldSpacing
    }

    view.addSubview(emailTextField)
    layout(emailTextField, emailLabel) { (emailTextField, emailLabel) in
      emailTextField.left == emailTextField.superview!.left + margin
      emailTextField.top == emailLabel.bottom + afterLabelSpacing
      emailTextField.right == emailTextField.superview!.right - margin
      emailTextField.height == textFieldHeight
    }

    logOutButton.addTarget(self, action: "signInButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(logOutButton)
    layout(logOutButton, emailTextField) { (logOutButton, emailTextField) in
      logOutButton.left == logOutButton.superview!.left + margin
      logOutButton.top == emailTextField.bottom + afterTextFieldSpacing
      logOutButton.right == logOutButton.superview!.right - margin
      logOutButton.height == 50
    }

    let chevronImage = UIImage(named: "chevron")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
    let logOutChevron = UIImageView(image: chevronImage)
    logOutChevron.tintColor = UIColor.redColor()
    logOutButton.addSubview(logOutChevron)
    layout(logOutChevron) { (logOutChevron) in
      logOutChevron.width == Float(chevronImage.size.width)
      logOutChevron.centerY == logOutChevron.superview!.centerY
      logOutChevron.right == logOutChevron.superview!.right - 25
      logOutChevron.height == Float(chevronImage.size.height)
    }

    view.backgroundColor = UIColor.whiteColor()
  }

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }
}