//
//  EditProfileViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/2/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import SwiftSpinner

class EditProfileViewController: UIViewController {

  // MARK: - Properties

  private let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: SnowballTopViewButtonType.Save, title: NSLocalizedString("Edit Profile", comment: ""))

  private let tableViewController = FormTableViewController()

  private var tableView: UITableView {
    return tableViewController.tableView
  }

  private let avatarButton = UIButton()

  private let avatarImageView: UserAvatarImageView = {
    let imageView = UserAvatarImageView()
    imageView.userInteractionEnabled = false
    if let user = User.currentUser {
      imageView.configureForUser(user)
    }
    return imageView
  }()

  private let editAvatarLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 14)
    label.text = NSLocalizedString("Edit", comment: "")
    label.textColor = User.currentUser?.color as? UIColor ?? UIColor.SnowballColor.blueColor
    return label
  }()

//  private let logOutButton: UIButton = {
//    let logOutButton = UIButton()
//    logOutButton.setTitle(NSLocalizedString("log out", comment: ""), forState: UIControlState.Normal)
//    logOutButton.setTitleColor(UIColor.redColor(), forState: UIControlState.Normal)
//    logOutButton.titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
//    logOutButton.alignLeft(insetWidth: 20)
//    logOutButton.showSnowballStyleBorderWithColor(UIColor.redColor())
//    return logOutButton
//  }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(topView)
    topView.setupDefaultLayout()

    let avatarButtonDiameter: CGFloat = 100
    let tableHeaderView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: avatarButtonDiameter + 20))
    tableView.tableHeaderView = tableHeaderView

    tableHeaderView.addSubview(avatarButton)
    avatarButton.addTarget(self, action: "avatarButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    constrain(avatarButton) { (avatarButton) in
      avatarButton.top == avatarButton.superview!.top
      avatarButton.centerX == avatarButton.superview!.centerX
      avatarButton.width == avatarButtonDiameter
      avatarButton.height == avatarButtonDiameter
    }

    avatarButton.addSubview(avatarImageView)
    constrain(avatarImageView) { (avatarImageView) in
      avatarImageView.left == avatarImageView.superview!.left
      avatarImageView.top == avatarImageView.superview!.top
      avatarImageView.width == avatarImageView.superview!.width
      avatarImageView.height == avatarImageView.superview!.height
    }

    tableHeaderView.addSubview(editAvatarLabel)
    constrain(editAvatarLabel, avatarImageView) { (editAvatarLabel, avatarImageView) in
      editAvatarLabel.top == avatarImageView.bottom + 5
      editAvatarLabel.centerX == editAvatarLabel.superview!.centerX
    }

    tableView.dataSource = self
    addChildViewController(tableViewController)
    view.addSubview(tableViewController.view)
    tableViewController.didMoveToParentViewController(self)
    constrain(tableViewController.view, topView) { (tableView, topView) in
      tableView.left == tableView.superview!.left
      tableView.top == topView.bottom
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }

//
//    logOutButton.addTarget(self, action: "logOutButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
//    view.addSubview(logOutButton)
//    constrain(logOutButton, emailTextField) { (logOutButton, emailTextField) in
//      logOutButton.left == logOutButton.superview!.left + margin
//      logOutButton.top == emailTextField.bottom + afterTextFieldSpacing
//      logOutButton.right == logOutButton.superview!.right - margin
//      logOutButton.height == 50
//    }
//
//    // When bringing this back from uncomment, this bad boy can be a snowballroundedbutton
//    let chevronImage = UIImage(named: "chevron")!.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
//    let logOutChevron = UIImageView(image: chevronImage)
//    logOutChevron.tintColor = UIColor.redColor()
//    logOutButton.addSubview(logOutChevron)
//    constrain(logOutChevron) { (logOutChevron) in
//      logOutChevron.width == Float(chevronImage.size.width)
//      logOutChevron.centerY == logOutChevron.superview!.centerY
//      logOutChevron.right == logOutChevron.superview!.right - 25
//      logOutChevron.height == Float(chevronImage.size.height)
//    }

    view.backgroundColor = UIColor.whiteColor()

    // TODO: prevent editing while loading this, but allow to go back
    SnowballAPI.requestObject(Router.GetCurrentUser) { (response: ObjectResponse<User>) in
      switch response {
      case .Success:
        self.tableView.reloadData()
        break
      case .Failure(let error): error.alertUser(); break
      }
    }
  }

  // MARK: - Private

  @objc private func avatarButtonTapped() {
    let imagePickerController = UIImagePickerController()
    imagePickerController.delegate = self
    imagePickerController.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
    imagePickerController.allowsEditing = true
    presentViewController(imagePickerController, animated: true, completion: nil)
  }
}

// MARK: -

private enum EditProfileTextFieldIndex: Int {
  case Username
  case Email
  case PhoneNumber
}

// MARK: - 

extension EditProfileViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }

  func snowballTopViewRightButtonTapped() {
    let user = User.currentUser!
    let usernameCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: EditProfileTextFieldIndex.Username.rawValue, inSection: 0)) as! TextFieldTableViewCell
    var username: String?
    if let text = usernameCell.textField.text {
      if user.username != text && text.characters.count > 0 {
        username = usernameCell.textField.text
        user.username = username
      }
    }
    let phoneNumberCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: EditProfileTextFieldIndex.PhoneNumber.rawValue, inSection: 0)) as! TextFieldTableViewCell
    var phoneNumber: String?
    if user.phoneNumber != phoneNumberCell.textField.text {
      phoneNumber = phoneNumberCell.textField.text
      user.phoneNumber = phoneNumber
    }
    let emailCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: EditProfileTextFieldIndex.Email.rawValue, inSection: 0)) as! TextFieldTableViewCell
    var email: String?
    if let text = emailCell.textField.text {
      if user.email != text && text.characters.count > 0 {
        email = emailCell.textField.text
        user.email = email
      }
    }
    if user.hasChanges {
      SnowballAPI.request(.UpdateCurrentUser(name: nil, username: username, email: email, phoneNumber: phoneNumber)) { response in
        switch response {
        case .Success:
          do { try user.managedObjectContext?.save() } catch {}
          self.navigationController?.popViewControllerAnimated(true);
        case .Failure(let error): error.alertUser()
        }
      }
    } else {
      navigationController?.popViewControllerAnimated(true)
    }
  }
}

// MARK: -

extension EditProfileViewController: UITableViewDataSource {

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

    let index = EditProfileTextFieldIndex(rawValue: indexPath.row)!
    switch(index) {
    case .Username:
      cell.descriptionLabel.text = NSLocalizedString("username", comment: "")
      cell.textField.setPlaceholder(NSLocalizedString("snowball", comment: ""), color: UIColor.SnowballColor.grayColor)
      cell.textField.text = User.currentUser?.username
    case .Email:
      cell.descriptionLabel.text = NSLocalizedString("email", comment: "")
      cell.textField.setPlaceholder(NSLocalizedString("hello@snowball.is", comment: ""), color: UIColor.SnowballColor.grayColor)
      cell.textField.text = User.currentUser?.email
      cell.textField.keyboardType = UIKeyboardType.EmailAddress
    case .PhoneNumber:
      cell.descriptionLabel.text = NSLocalizedString("phone number", comment: "")
      cell.textField.setPlaceholder(NSLocalizedString("4151234567", comment: ""), color: UIColor.SnowballColor.grayColor)
      cell.textField.text = User.currentUser?.phoneNumber
      cell.textField.keyboardType = UIKeyboardType.PhonePad
    }
  }
}

// MARK: -

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  // MARK: - UIImagePickerControllerDelegate

  func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
    SwiftSpinner.show("Uploading...", animated: true)
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

        API.changeAvatarToImage(processedImage) { (request, response, JSON, error) in
          SwiftSpinner.hide()
          if let _ = error {
            // displayAPIErrorToUser(JSON)
          } else {
            if let data = UIImagePNGRepresentation(processedImage), let imageURL = editingInfo[UIImagePickerControllerReferenceURL] as? NSURL, let user = User.currentUser {
              if let cacheURL = Cache.sharedCache.setDataForRemoteURL(data: data, remoteURL: imageURL) {
                user.avatarURL = cacheURL.absoluteString
                do { try user.managedObjectContext?.save() } catch {}
                self.avatarImageView.configureForUser(user)
              }
            }
          }
        }
      }
    }
  }

}