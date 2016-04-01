//
//  EditProfileViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/31/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import Haneke
import SwiftSpinner
import UIKit

class EditProfileViewController: UIViewController {

  // MARK: Properties

  let userAvatarImageView: UserAvatarImageView = {
    let imageView = UserAvatarImageView()
    if let user = User.currentUser {
      imageView.setUser(user)
    }
    return imageView
  }()
  let editAvatarButton: UIButton = {
    let button = UIButton()
    button.setTitle(NSLocalizedString("Edit", comment: ""), forState: .Normal)
    if let user = User.currentUser {
      button.setTitleColor(user.color, forState: .Normal)
    }
    return button
  }()
  let usernameTextFieldContainer: TextFieldContainerView = {
    let textFieldContainer = TextFieldContainerView()
    textFieldContainer.configureText(hint: NSLocalizedString("Username", comment: ""), placeholder: NSLocalizedString("Your username", comment: ""))
    textFieldContainer.textField.autocapitalizationType = .None
    textFieldContainer.textField.autocorrectionType = .No
    textFieldContainer.textField.spellCheckingType = .No
    textFieldContainer.textField.returnKeyType = .Done
    if let user = User.currentUser {
      textFieldContainer.textField.text = user.username
    }
    return textFieldContainer
  }()
  let emailTextFieldContainer: TextFieldContainerView = {
    let textFieldContainer = TextFieldContainerView()
    textFieldContainer.configureText(hint: NSLocalizedString("Email", comment: ""), placeholder: NSLocalizedString("Your email address", comment: ""))
    textFieldContainer.textField.autocapitalizationType = .None
    textFieldContainer.textField.autocorrectionType = .No
    textFieldContainer.textField.spellCheckingType = .No
    textFieldContainer.textField.keyboardType = .EmailAddress
    textFieldContainer.textField.returnKeyType = .Done
    if let user = User.currentUser {
      textFieldContainer.textField.text = user.email
    }
    return textFieldContainer
  }()
  let phoneNumberTextFieldContainer: TextFieldContainerView = {
    let textFieldContainer = TextFieldContainerView()
    textFieldContainer.configureText(hint: NSLocalizedString("Phone Number", comment: ""), placeholder: NSLocalizedString("Your phone number", comment: ""))
    textFieldContainer.textField.autocapitalizationType = .None
    textFieldContainer.textField.autocorrectionType = .No
    textFieldContainer.textField.spellCheckingType = .No
    textFieldContainer.textField.keyboardType = .NumberPad
    textFieldContainer.textField.returnKeyType = .Done
    if let user = User.currentUser {
      textFieldContainer.textField.text = user.phoneNumber
    }
    return textFieldContainer
  }()

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("Edit profile", comment: "")
    view.backgroundColor = UIColor.whiteColor()

    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-back-black"), style: .Plain, target: self, action: #selector(EditProfileViewController.leftBarButtonItemPressed))
    navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Save", comment: ""), style: .Plain, target: self, action: #selector(EditProfileViewController.rightBarButtonItemPressed))
    navigationItem.rightBarButtonItem?.tintColor = UIColor.blackColor()

    view.addSubview(userAvatarImageView)
    constrain(userAvatarImageView) { userAvatarImageView in
      userAvatarImageView.top == userAvatarImageView.superview!.top + navigationBarOffset
      userAvatarImageView.centerX == userAvatarImageView.superview!.centerX
      userAvatarImageView.height == 100
      userAvatarImageView.width == 100
    }

    view.addSubview(editAvatarButton)
    constrain(editAvatarButton, userAvatarImageView) { editAvatarButton, userAvatarImageView in
      editAvatarButton.top == userAvatarImageView.bottom + 5
      editAvatarButton.centerX == userAvatarImageView.centerX
      editAvatarButton.height == 44
    }
    editAvatarButton.addTarget(self, action: #selector(EditProfileViewController.editAvatarButtonPressed), forControlEvents: .TouchUpInside)

    view.addSubview(usernameTextFieldContainer)
    constrain(usernameTextFieldContainer, editAvatarButton) { usernameTextFieldContainer, editAvatarButton in
      usernameTextFieldContainer.left == usernameTextFieldContainer.superview!.left + TextFieldContainerView.defaultSideMargin
      usernameTextFieldContainer.top == editAvatarButton.bottom + 10
      usernameTextFieldContainer.right == usernameTextFieldContainer.superview!.right - TextFieldContainerView.defaultSideMargin
      usernameTextFieldContainer.height == TextFieldContainerView.defaultHeight
    }
    usernameTextFieldContainer.textField.delegate = self

    view.addSubview(emailTextFieldContainer)
    constrain(emailTextFieldContainer, usernameTextFieldContainer) { emailTextFieldContainer, usernameTextFieldContainer in
      emailTextFieldContainer.left == usernameTextFieldContainer.left
      emailTextFieldContainer.top == usernameTextFieldContainer.bottom + TextFieldContainerView.defaultSpaceBetween
      emailTextFieldContainer.right == usernameTextFieldContainer.right
      emailTextFieldContainer.height == usernameTextFieldContainer.height
    }
    emailTextFieldContainer.textField.delegate = self
    emailTextFieldContainer.linkSizingWithTextFieldContainerView(usernameTextFieldContainer)

    view.addSubview(phoneNumberTextFieldContainer)
    constrain(phoneNumberTextFieldContainer, emailTextFieldContainer) { phoneNumberTextFieldContainer, emailTextFieldContainer in
      phoneNumberTextFieldContainer.left == emailTextFieldContainer.left
      phoneNumberTextFieldContainer.top == emailTextFieldContainer.bottom + TextFieldContainerView.defaultSpaceBetween
      phoneNumberTextFieldContainer.right == emailTextFieldContainer.right
      phoneNumberTextFieldContainer.height == emailTextFieldContainer.height
    }
    phoneNumberTextFieldContainer.textField.delegate = self
    phoneNumberTextFieldContainer.linkSizingWithTextFieldContainerView(emailTextFieldContainer)
  }

  // MARK: Private

  @objc private func leftBarButtonItemPressed() {
    navigationController?.popViewControllerAnimated(true)
  }

  @objc private func rightBarButtonItemPressed() {
    guard let user = User.currentUser else { return }

    var hasChanges = false

    var newUsername: String?
    if let text = usernameTextFieldContainer.textField.text {
      if user.username != text && text.characters.count > 0 {
        newUsername = usernameTextFieldContainer.textField.text
        hasChanges = true
      }
    }

    var newEmail: String?
    if let text = emailTextFieldContainer.textField.text {
      if user.email != text && text.characters.count > 0 {
        newEmail = emailTextFieldContainer.textField.text
        hasChanges = true
      }
    }

    var newPhoneNumber: String?
    if let text = phoneNumberTextFieldContainer.textField.text {
      if user.phoneNumber != text && text.characters.count > 0 {
        newPhoneNumber = phoneNumberTextFieldContainer.textField.text
        hasChanges = true
      }
    }

    if hasChanges {
      SwiftSpinner.show(NSLocalizedString("Updating...", comment: ""), animated: true)
      SnowballAPI.request(SnowballRoute.UpdateCurrentUser(username: newUsername, email: newEmail, phoneNumber: newPhoneNumber)) { response in
        SwiftSpinner.hide()
        switch response {
        case .Success:
          Database.performTransaction {
            if let username = newUsername {
              user.username = username
            }
            if let email = newEmail {
              user.email = email
            }
            if let phoneNumber = newPhoneNumber {
              user.phoneNumber = phoneNumber
            }
            Database.save(user)
          }
          self.navigationController?.popViewControllerAnimated(true)

        case .Failure(let error): error.displayToUserIfAppropriateFromViewController(self)
        }
      }
    } else {
      navigationController?.popViewControllerAnimated(true)
    }
  }

  @objc private func editAvatarButtonPressed() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    imagePickerController.allowsEditing = true
    presentViewController(imagePickerController, animated: true, completion: nil)
  }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    SwiftSpinner.show(NSLocalizedString("Uploading...", comment: ""), animated: true)
    picker.dismissViewControllerAnimated(true) {
      dispatch_async(dispatch_get_main_queue()) {
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: UIStatusBarAnimation.Fade)
        let editedImage = editingInfo[UIImagePickerControllerEditedImage] as? UIImage
        var finalImage: UIImage
        if let editedImage = editedImage {
          finalImage = editedImage
        } else {
          finalImage = image
        }
        let rect = CGRectMake(0, 0, 480, 480)
        UIGraphicsBeginImageContext(rect.size)
        finalImage.drawInRect(rect)
        let processedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        SnowballAPI.uploadUserAvatar(processedImage) { (response) in
          SwiftSpinner.hide()
          let resetAvatarImageView = {
            if let user = User.currentUser, avatarURL = user.avatarURL {
              let cache = Shared.imageCache
              cache.set(value: processedImage, key: avatarURL, formatName: "original") { _ in
                self.userAvatarImageView.setUser(user)
              }
            }
          }
          resetAvatarImageView() // TODO: This should be in success only, but the server doesn't reply with JSON when sending a 204 right now.
          switch response {
          case .Success: break
          case .Failure(let error): error.displayToUserIfAppropriateFromViewController(self)
          }
        }
      }
    }
  }
}

extension EditProfileViewController: UITextFieldDelegate {
  func textFieldShouldReturn(textField: UITextField) -> Bool {
    return true
  }
}