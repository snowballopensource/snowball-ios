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
    button.setTitle(NSLocalizedString("Edit", comment: ""), for: UIControlState())
    if let user = User.currentUser {
      button.setTitleColor(user.color, for: UIControlState())
    }
    return button
  }()
  let usernameTextField: FormTextField = {
    let textField = FormTextField()
    textField.hint = NSLocalizedString("Username", comment: "")
    textField.placeholder = NSLocalizedString("Your username", comment: "")
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.spellCheckingType = .no
    textField.returnKeyType = .done
    if let user = User.currentUser {
      textField.text = user.username
    }
    return textField
  }()
  let emailTextField: FormTextField = {
    let textField = FormTextField()
    textField.hint = NSLocalizedString("Email", comment: "")
    textField.placeholder = NSLocalizedString("Your email address", comment: "")
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.spellCheckingType = .no
    textField.keyboardType = .emailAddress
    textField.returnKeyType = .done
    if let user = User.currentUser {
      textField.text = user.email
    }
    return textField
  }()
  let phoneNumberTextField: FormTextField = {
    let textField = FormTextField()
    textField.hint = NSLocalizedString("Phone Number", comment: "")
    textField.placeholder = NSLocalizedString("Your phone number", comment: "")
    textField.autocapitalizationType = .none
    textField.autocorrectionType = .no
    textField.spellCheckingType = .no
    textField.keyboardType = .numberPad
    textField.returnKeyType = .done
    if let user = User.currentUser {
      textField.text = user.phoneNumber
    }
    return textField
  }()

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("Edit profile", comment: "")
    view.backgroundColor = UIColor.white

    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-back-black"), style: .plain, target: self, action: #selector(EditProfileViewController.leftBarButtonItemPressed))
    navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: NSLocalizedString("Save", comment: ""), style: .plain, target: self, action: #selector(EditProfileViewController.rightBarButtonItemPressed))
    navigationItem.rightBarButtonItem?.tintColor = UIColor.black

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
    editAvatarButton.addTarget(self, action: #selector(EditProfileViewController.editAvatarButtonPressed), for: .touchUpInside)

    view.addSubview(usernameTextField)
    constrain(usernameTextField, editAvatarButton) { usernameTextField, editAvatarButton in
      usernameTextField.left == usernameTextField.superview!.left + FormTextField.defaultSideMargin
      usernameTextField.top == editAvatarButton.bottom + 10
      usernameTextField.right == usernameTextField.superview!.right - FormTextField.defaultSideMargin
      usernameTextField.height == FormTextField.defaultHeight
    }
    usernameTextField.delegate = self

    view.addSubview(emailTextField)
    constrain(emailTextField, usernameTextField) { emailTextField, usernameTextField in
      emailTextField.left == usernameTextField.left
      emailTextField.top == usernameTextField.bottom + FormTextField.defaultSpaceBetween
      emailTextField.right == usernameTextField.right
      emailTextField.height == usernameTextField.height
    }
    emailTextField.delegate = self

    view.addSubview(phoneNumberTextField)
    constrain(phoneNumberTextField, emailTextField) { phoneNumberTextField, emailTextField in
      phoneNumberTextField.left == emailTextField.left
      phoneNumberTextField.top == emailTextField.bottom + FormTextField.defaultSpaceBetween
      phoneNumberTextField.right == emailTextField.right
      phoneNumberTextField.height == emailTextField.height
    }
    phoneNumberTextField.delegate = self

    FormTextField.linkFormTextFieldsHintSizing([usernameTextField, emailTextField, phoneNumberTextField])
  }

  // MARK: Private

  @objc private func leftBarButtonItemPressed() {
    navigationController?.popViewController(animated: true)
  }

  @objc private func rightBarButtonItemPressed() {
    guard let user = User.currentUser else { return }

    var hasChanges = false

    var newUsername: String?
    if let text = usernameTextField.text {
      if user.username != text && text.characters.count > 0 {
        newUsername = usernameTextField.text
        hasChanges = true
      }
    }

    var newEmail: String?
    if let text = emailTextField.text {
      if user.email != text && text.characters.count > 0 {
        newEmail = emailTextField.text
        hasChanges = true
      }
    }

    var newPhoneNumber: String?
    if let text = phoneNumberTextField.text {
      if user.phoneNumber != text && text.characters.count > 0 {
        newPhoneNumber = phoneNumberTextField.text
        hasChanges = true
      }
    }

    if hasChanges {
      SwiftSpinner.show(NSLocalizedString("Updating...", comment: ""), animated: true)
      SnowballAPI.request(SnowballRoute.updateCurrentUser(username: newUsername, email: newEmail, phoneNumber: newPhoneNumber)) { response in
        SwiftSpinner.hide()
        switch response {
        case .success:
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
          self.navigationController?.popViewController(animated: true)

        case .failure(let error): error.displayToUserIfAppropriateFromViewController(self)
        }
      }
    } else {
      navigationController?.popViewController(animated: true)
    }
  }

  @objc private func editAvatarButtonPressed() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = UIImagePickerControllerSourceType.photoLibrary
    imagePickerController.allowsEditing = true
    present(imagePickerController, animated: true, completion: nil)
  }
}

// MARK: UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [AnyHashable: Any]!) {
    SwiftSpinner.show(NSLocalizedString("Uploading...", comment: ""), animated: true)
    picker.dismiss(animated: true) {
      DispatchQueue.main.async {
        UIApplication.shared.setStatusBarHidden(true, with: UIStatusBarAnimation.fade)
        let editedImage = editingInfo[UIImagePickerControllerEditedImage] as? UIImage
        var finalImage: UIImage
        if let editedImage = editedImage {
          finalImage = editedImage
        } else {
          finalImage = image
        }
        let rect = CGRect(x: 0, y: 0, width: 480, height: 480)
        UIGraphicsBeginImageContext(rect.size)
        finalImage.draw(in: rect)
        guard let processedImage = UIGraphicsGetImageFromCurrentImageContext() else {
          preconditionFailure()
        }
        UIGraphicsEndImageContext()

        SnowballAPI.uploadUserAvatar(processedImage) { (response) in
          SwiftSpinner.hide()
          let resetAvatarImageView = {
            if let user = User.currentUser, let avatarURL = user.avatarURL {
              let cache = Shared.imageCache
              cache.set(value: processedImage, key: avatarURL, formatName: "original") { _ in
                self.userAvatarImageView.setUser(user)
              }
            }
          }
          resetAvatarImageView() // TODO: This should be in success only, but the server doesn't reply with JSON when sending a 204 right now.
          switch response {
          case .success: break
          case .failure(let error): error.displayToUserIfAppropriateFromViewController(self)
          }
        }
      }
    }
  }
}

extension EditProfileViewController: UITextFieldDelegate {
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    return true
  }
}
