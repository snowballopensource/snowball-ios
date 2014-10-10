//
//  PhoneNumberChangeViewController.swift
//  Snowball
//
//  Created by James Martinez on 10/10/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class PhoneNumberChangeViewController: UIViewController {
  private let currentUser = User.currentUser!
  private let phoneNumberTextField = UITextField()

  func changePhoneNumber() {
    var newPhoneNumber: String?
    if phoneNumberTextField.text != currentUser.phoneNumber {
      newPhoneNumber = phoneNumberTextField.text
    }
    if newPhoneNumber != nil {
      API.request(APIRoute.ChangePhoneNumber(phoneNumber: newPhoneNumber!)).responseObject{ (object, error) in
        if error != nil { error?.display(); return }
        self.navigationController?.pushViewController(PhoneNumberVerificationViewController(), animated: true)
      }
    } else {
      self.navigationController?.popViewControllerAnimated(true)
    }
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    title = NSLocalizedString("Phone Number")

    let rightBarButton = UIButton(frame: CGRectMake(0, 0, 44.0, 44.0))
    rightBarButton.setTitle(NSLocalizedString("✓"), forState: UIControlState.Normal)
    rightBarButton.addTarget(self, action: "changePhoneNumber", forControlEvents: UIControlEvents.TouchUpInside)
    rightBarButton.setTitleColorWithAutomaticHighlightColor()
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)

    phoneNumberTextField.placeholder = currentUser.phoneNumber
    phoneNumberTextField.keyboardType = UIKeyboardType.PhonePad
    phoneNumberTextField.borderStyle = UITextBorderStyle.RoundedRect
    view.addSubview(phoneNumberTextField)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let margin: Float = 20.0

    layout(phoneNumberTextField) { (phoneNumberTextField) in
      phoneNumberTextField.left == phoneNumberTextField.superview!.left + margin
      phoneNumberTextField.right == phoneNumberTextField.superview!.right - margin
      phoneNumberTextField.top == phoneNumberTextField.superview!.top + margin
      phoneNumberTextField.height == 50
    }
  }
}