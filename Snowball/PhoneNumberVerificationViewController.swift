//
//  PhoneNumberVerificationViewController.swift
//  Snowball
//
//  Created by James Martinez on 10/10/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class PhoneNumberVerificationViewController: UIViewController {
  private let verificationCodeTextField = UITextField()

  func verifyPhoneNumber() {
    if countElements(verificationCodeTextField.text) == 4 {
      var userID = ""
      if let currentUser = User.currentUser {
        userID = currentUser.id
      } else {
        let user = User.allObjects().firstObject() as User
        userID = user.id
      }
      API.request(APIRoute.PhoneVerification(userID: userID, phoneNumberVerificationCode: verificationCodeTextField.text)).responsePersistable(User.self) { (object, error) in
        if error != nil { error?.display(); return }
        if let navigationController = self.navigationController as? AuthenticationNavigationController {
          switchToNavigationController(MainNavigationController())
        } else {
          self.navigationController?.popToRootViewControllerAnimated(true)
        }
      }
    } else {
      // TODO: don't go forward, figure out ux for that
    }
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.whiteColor()

    title = NSLocalizedString("Verify Phone Number")

    let rightBarButton = UIButton(frame: CGRectMake(0, 0, 44.0, 44.0))
    rightBarButton.setTitle(NSLocalizedString("✓"), forState: UIControlState.Normal)
    rightBarButton.addTarget(self, action: "verifyPhoneNumber", forControlEvents: UIControlEvents.TouchUpInside)
    rightBarButton.setTitleColorWithAutomaticHighlightColor()
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightBarButton)

    let margin: Float = 20.0

    verificationCodeTextField.keyboardType = UIKeyboardType.NumberPad
    verificationCodeTextField.borderStyle = UITextBorderStyle.RoundedRect
    view.addSubview(verificationCodeTextField)
    layout(verificationCodeTextField) { (verificationCodeTextField) in
      verificationCodeTextField.left == verificationCodeTextField.superview!.left + margin
      verificationCodeTextField.right == verificationCodeTextField.superview!.right - margin
      verificationCodeTextField.top == verificationCodeTextField.superview!.top + margin
      verificationCodeTextField.height == 50
    }
  }
}