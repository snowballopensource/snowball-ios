//
//  EditProfileViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/2/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation

class EditProfileViewController: UIViewController {

  // MARK: - Properties

  private let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: SnowballTopViewButtonType.Save, title: "Edit Profile")

  private let tableView = FormTableView()

  private let avatarButton = UIButton()

  private let avatarImageView: UserAvatarImageView = {
    let imageView = UserAvatarImageView()
    imageView.userInteractionEnabled = false
    if let user = User.currentUser {
      imageView.configureForUser(user)
    }
    return imageView
  }()

//  private let logOutButton: UIButton = {
//    let logOutButton = UIButton()
//    logOutButton.setTitle(NSLocalizedString("log out"), forState: UIControlState.Normal)
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

    avatarButton.addTarget(self, action: "avatarButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(avatarButton)
    layout(avatarButton, topView) { (avatarButton, topView) in
      avatarButton.top == topView.bottom
      avatarButton.centerX == avatarButton.superview!.centerX
      let diameter: Float = 100
      avatarButton.width == diameter
      avatarButton.height == diameter
    }

    avatarImageView.frame = avatarButton.bounds
    avatarButton.addSubview(avatarImageView)

    tableView.dataSource = self
    view.addSubview(tableView)
    layout(tableView, avatarImageView) { (tableView, avatarImageView) in
      tableView.left == tableView.superview!.left
      tableView.top == avatarImageView.bottom
      tableView.right == tableView.superview!.right
      tableView.bottom == tableView.superview!.bottom
    }

//
//    logOutButton.addTarget(self, action: "logOutButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
//    view.addSubview(logOutButton)
//    layout(logOutButton, emailTextField) { (logOutButton, emailTextField) in
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
//    layout(logOutChevron) { (logOutChevron) in
//      logOutChevron.width == Float(chevronImage.size.width)
//      logOutChevron.centerY == logOutChevron.superview!.centerY
//      logOutChevron.right == logOutChevron.superview!.right - 25
//      logOutChevron.height == Float(chevronImage.size.height)
//    }

    view.backgroundColor = UIColor.whiteColor()

    // TODO: prevent editing while loading this, but allow to go back
    API.request(Router.GetCurrentUser).responseJSON { (request, response, JSON, error) in
      error?.print("api get current user")
      if error != nil { displayAPIErrorToUser(JSON); return }
      if let JSON: AnyObject = JSON {
        dispatch_async(dispatch_get_main_queue()) {
          User.objectFromJSON(JSON)
          self.tableView.reloadData()
        }
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
  case PhoneNumber
  case Email
}

// MARK: - 

extension EditProfileViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }

  func snowballTopViewRightButtonTapped() {
    let user = User.currentUser!
    let usernameCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: EditProfileTextFieldIndex.Username.rawValue, inSection: 0)) as TextFieldTableViewCell
    var username: String?
    if user.username != usernameCell.textField.text && countElements(usernameCell.textField.text) > 0 {
      username = usernameCell.textField.text
      user.username = username
    }
    let phoneNumberCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: EditProfileTextFieldIndex.PhoneNumber.rawValue, inSection: 0)) as TextFieldTableViewCell
    var phoneNumber: String?
    if user.phoneNumber != phoneNumberCell.textField.text {
      phoneNumber = phoneNumberCell.textField.text
      user.phoneNumber = phoneNumber
    }
    let emailCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: EditProfileTextFieldIndex.Email.rawValue, inSection: 0)) as TextFieldTableViewCell
    var email: String?
    if user.email != emailCell.textField.text && countElements(emailCell.textField.text) > 0 {
      email = emailCell.textField.text
      user.email = email
    }
    if user.hasChanges {
      API.request(Router.UpdateCurrentUser(name: nil, username: username, email: email, phoneNumber: phoneNumber)).responseJSON { (request, response, JSON, error) in
        error?.print("api update current user")
        if error != nil { displayAPIErrorToUser(JSON); return }
        user.managedObjectContext?.save(nil)
        self.navigationController?.popViewControllerAnimated(true)
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
      forIndexPath: indexPath) as UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  // MARK: - Private

  private func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cell = cell as TextFieldTableViewCell

    cell.textField.autocorrectionType = UITextAutocorrectionType.No
    cell.textField.autocapitalizationType = UITextAutocapitalizationType.None
    cell.textField.keyboardType = UIKeyboardType.Default

    let index = EditProfileTextFieldIndex(rawValue: indexPath.row)!
    switch(index) {
    case .Username:
      cell.textField.setPlaceholder(NSLocalizedString("username"), color: cell.textField.tintColor)
      cell.textField.text = User.currentUser?.username
    case .PhoneNumber:
      cell.textField.setPlaceholder(NSLocalizedString("phone number"), color: cell.textField.tintColor)
      cell.textField.text = User.currentUser?.phoneNumber
      cell.textField.keyboardType = UIKeyboardType.PhonePad
    case .Email:
      cell.textField.setPlaceholder(NSLocalizedString("email"), color: cell.textField.tintColor)
      cell.textField.text = User.currentUser?.email
      cell.textField.keyboardType = UIKeyboardType.EmailAddress
    }
  }
}

// MARK: - 

extension EditProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

  // MARK: - UIImagePickerControllerDelegate

  func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
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

        // TODO: show spinner while uploading, show final image when done
        self.avatarImageView.imageView.image = processedImage
        API.changeAvatarToImage(processedImage) { (request, response, JSON, error) in
          if let error = error {
            error.print("change avatar")
            displayAPIErrorToUser(JSON)
          }
        }
      }
    }
  }

}