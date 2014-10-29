//
//  PhoneNumberChangeViewController.swift
//  Snowball
//
//  Created by James Martinez on 10/10/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class PhoneNumberChangeViewController: UIViewController, UITextFieldDelegate {
  private let currentUser = User.currentUser!
  private let countryCodeTextField = UITextField()
  private let phoneNumberTextField = UITextField()

  func changePhoneNumber() {
    let phoneNumberString = countryCodeTextField.text + phoneNumberTextField.text
    let newPhoneNumber = PhoneNumber(string: phoneNumberString)
    if newPhoneNumber.matchesPhoneNumberString(currentUser.phoneNumber) {
      self.navigationController?.popViewControllerAnimated(true)
    } else {
      if newPhoneNumber.isPlausible() {
        API.request(APIRoute.ChangePhoneNumber(phoneNumber: newPhoneNumber.E164String)).responseObject{ (object, error) in
          if error != nil { error?.display(); return }
          self.navigationController?.pushViewController(PhoneNumberVerificationViewController(), animated: true)
        }
      } else {
        // TODO: display invalid phone number error
        println("Invalid phone number.")
      }
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

    let phoneNumber = PhoneNumber(string: currentUser.phoneNumber)

    countryCodeTextField.text = "+"
    if let countryCode = phoneNumber.countryCode {
      countryCodeTextField.text = "+" + countryCode
    }
    countryCodeTextField.keyboardType = UIKeyboardType.NumberPad
    countryCodeTextField.borderStyle = UITextBorderStyle.RoundedRect
    countryCodeTextField.delegate = self
    view.addSubview(countryCodeTextField)
    phoneNumberTextField.text = phoneNumber.nationalNumber
    phoneNumberTextField.keyboardType = UIKeyboardType.NumberPad
    phoneNumberTextField.borderStyle = UITextBorderStyle.RoundedRect
    phoneNumberTextField.delegate = self
    view.addSubview(phoneNumberTextField)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    let margin: Float = 20.0

    layout(countryCodeTextField) { (countryCodeTextField) in
      countryCodeTextField.left == countryCodeTextField.superview!.left + margin
      countryCodeTextField.width == 100
      countryCodeTextField.top == countryCodeTextField.superview!.top + margin
      countryCodeTextField.height == 50
    }
    layout(phoneNumberTextField, countryCodeTextField) { (phoneNumberTextField, countryCodeTextField) in
      phoneNumberTextField.left == countryCodeTextField.right
      phoneNumberTextField.right == phoneNumberTextField.superview!.right - margin
      phoneNumberTextField.top == countryCodeTextField.top
      phoneNumberTextField.height == countryCodeTextField.height
    }
  }

  // MARK: UITextFieldDelegate

  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField == countryCodeTextField {
      let textFieldText = countryCodeTextField.text as NSString
      let resultString = textFieldText.stringByReplacingCharactersInRange(range, withString: string) as NSString
      if resultString.rangeOfString("+").location == 0 {
        return true
      }
      return false
    }
    return true
  }
}