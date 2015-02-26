//
//  PhoneNumberViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/20/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class PhoneNumberViewController: UIViewController {

  // MARK: - Properties

  let topBar = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: SnowballTopViewButtonType.Forward)

  let messageLabel: UILabel = {
    let messageLabel = UILabel()
    messageLabel.numberOfLines = 0
    messageLabel.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    return messageLabel
  }()

  let countryCodeTextField: UITextField = {
    let countryCodeTextField = UITextField()
    countryCodeTextField.backgroundColor = UIColor.SnowballColor.greenColor
    countryCodeTextField.keyboardType = UIKeyboardType.PhonePad
    countryCodeTextField.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
    countryCodeTextField.text = "+1"
    countryCodeTextField.font = UIFont(name: "Helvetica", size: 24)
    countryCodeTextField.textColor = UIColor.whiteColor()
    countryCodeTextField.textAlignment = NSTextAlignment.Center
    countryCodeTextField.tintColor = UIColor.whiteColor()
    return countryCodeTextField
  }()

  let phoneNumberTextField: UITextField = {
    let phoneNumberTextField = UITextField()
    phoneNumberTextField.keyboardType = UIKeyboardType.PhonePad
    phoneNumberTextField.showSnowballStyleBorderWithColor(UIColor.SnowballColor.greenColor)
    phoneNumberTextField.attributedPlaceholder = NSAttributedString(string: "4151234567", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor])
    phoneNumberTextField.font = UIFont(name: "Helvetica", size: 28)
    phoneNumberTextField.textColor = UIColor.SnowballColor.greenColor
    phoneNumberTextField.textAlignment = NSTextAlignment.Center
    phoneNumberTextField.tintColor = UIColor.SnowballColor.greenColor
    return phoneNumberTextField
  }()

  let disclaimerLabel: UILabel = {
    let disclaimerLabel = UILabel()
    disclaimerLabel.text = NSLocalizedString("No one will ever see your phone number on Snowball.")
    disclaimerLabel.font = UIFont(name: UIFont.SnowballFont.bold, size: 10)
    disclaimerLabel.textColor = UIColor.SnowballColor.greenColor
    return disclaimerLabel
  }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topBar)
    topBar.setupDefaultLayout()

    let messageStringOne = NSAttributedString(string: "Next, we need your ", attributes: [NSForegroundColorAttributeName: UIColor.blackColor()])
    let messageStringTwo = NSAttributedString(string: "phone number, ", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
    let messageStringThree = NSAttributedString(string: "so we can help your friends find you.", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor])
    let messageString = NSMutableAttributedString(attributedString: messageStringOne)
    messageString.appendAttributedString(messageStringTwo)
    messageString.appendAttributedString(messageStringThree)
    messageLabel.attributedText = messageString
    view.addSubview(messageLabel)
    layout(messageLabel, topBar) { (messageLabel, topBar) in
      let sideMargin: Float = 40
      messageLabel.left == messageLabel.superview!.left + sideMargin
      messageLabel.top == topBar.bottom
      messageLabel.right == messageLabel.superview!.right - sideMargin
    }

    view.addSubview(countryCodeTextField)
    layout(countryCodeTextField) { (countryCodeTextField) in
      countryCodeTextField.left == countryCodeTextField.superview!.left + 25
      countryCodeTextField.top == countryCodeTextField.superview!.top + 180
      countryCodeTextField.width == 90
      countryCodeTextField.height == 50
    }

    view.addSubview(phoneNumberTextField)
    layout(phoneNumberTextField, countryCodeTextField) { (phoneNumberTextField, countryCodeTextField) in
      phoneNumberTextField.left == countryCodeTextField.right + 10
      phoneNumberTextField.top == countryCodeTextField.top
      phoneNumberTextField.right == phoneNumberTextField.superview!.right - 25
      phoneNumberTextField.height == countryCodeTextField.height
    }

    view.addSubview(disclaimerLabel)
    layout(disclaimerLabel, phoneNumberTextField) { (disclaimerLabel, phoneNumberTextField) in
      disclaimerLabel.centerX == disclaimerLabel.superview!.centerX
      disclaimerLabel.top == phoneNumberTextField.bottom + 30
    }

    phoneNumberTextField.becomeFirstResponder()
  }
}

// MARK: - 

extension PhoneNumberViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }

  func snowballTopViewRightButtonTapped() {
    let newPhoneNumber = "\(countryCodeTextField.text)\(phoneNumberTextField.text)"
    if countElements(newPhoneNumber) > 5 {
      API.request(Router.UpdateCurrentUser(name: nil, username: nil, email: nil, phoneNumber: newPhoneNumber)).responseJSON { (request, response, JSON, error) in
        if let error = error {
          displayAPIErrorToUser(JSON)
          error.print("add phone number to new user")
        } else {
          Analytics.track("Add Phone Number During Onboarding")
          self.switchToNavigationController(MainNavigationController())
        }
      }
    } else {
      switchToNavigationController(MainNavigationController())
    }
  }
}
