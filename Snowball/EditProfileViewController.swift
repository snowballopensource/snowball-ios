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

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    title = NSLocalizedString("Edit profile", comment: "")
    view.backgroundColor = UIColor.whiteColor()

    navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-back-black"), style: .Plain, target: self, action: #selector(EditProfileViewController.leftBarButtonItemPressed))

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
  }

  // MARK: Private

  @objc private func leftBarButtonItemPressed() {
    navigationController?.popViewControllerAnimated(true)
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