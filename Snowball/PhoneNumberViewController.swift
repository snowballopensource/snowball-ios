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

  private let topBar = SnowballTopView(leftButtonType: nil, rightButtonType: SnowballTopViewButtonType.Forward)

  private let messageLabel: UILabel = {
    let label = UILabel()
    label.numberOfLines = 0
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    let messageString = NSMutableAttributedString()
    messageString.appendAttributedString(NSAttributedString(string: "Next, we need your ", attributes: [NSForegroundColorAttributeName: UIColor.blackColor()]))
    messageString.appendAttributedString(NSAttributedString(string: "phone number, ", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.blueColor]))
    messageString.appendAttributedString(NSAttributedString(string: "so we can help your friends find you.", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor]))
    label.attributedText = messageString
    return label
  }()

  private let countryCodeTextField: SnowballRoundedTextField = {
    let textField = SnowballRoundedTextField()
    textField.backgroundColor = UIColor.SnowballColor.blueColor
    textField.keyboardType = UIKeyboardType.PhonePad
    textField.text = "+1"
    textField.font = UIFont(name: "Helvetica", size: 24)
    textField.alignLeft(0)
    textField.textAlignment = NSTextAlignment.Center
    textField.tintColor = UIColor.whiteColor()
    return textField
  }()

  private let phoneNumberTextField: SnowballRoundedTextField = {
    let textField = SnowballRoundedTextField()
    textField.keyboardType = UIKeyboardType.PhonePad
    textField.attributedPlaceholder = NSAttributedString(string: "4151234567", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor])
    textField.font = UIFont(name: "Helvetica", size: 28)
    textField.alignLeft(0)
    textField.textAlignment = NSTextAlignment.Center
    textField.tintColor = UIColor.SnowballColor.blueColor
    return textField
  }()

  private let disclaimerLabel: UILabel = {
    let label = UILabel()
    label.text = NSLocalizedString("No one will ever see your phone number on Snowball.", comment: "")
    label.font = UIFont(name: UIFont.SnowballFont.bold, size: 10)
    label.textColor = UIColor.SnowballColor.blueColor
    return label
  }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topBar)
    topBar.setupDefaultLayout()

    view.addSubview(messageLabel)
    layout(messageLabel, topBar) { (messageLabel, topBar) in
      let sideMargin: Float = 40
      messageLabel.left == messageLabel.superview!.left + sideMargin
      messageLabel.top == topBar.bottom
      messageLabel.right == messageLabel.superview!.right - sideMargin
    }

    view.addSubview(countryCodeTextField)
    layout(countryCodeTextField, messageLabel) { (countryCodeTextField, messageLabel) in
      countryCodeTextField.left == countryCodeTextField.superview!.left + 25
      countryCodeTextField.top == messageLabel.bottom + 15
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

  func snowballTopViewRightButtonTapped() {
    let newPhoneNumber = "\(countryCodeTextField.text)\(phoneNumberTextField.text)"
    if newPhoneNumber.characters.count > 5 {
      topBar.spinRightButton(true)
      API.request(Router.UpdateCurrentUser(name: nil, username: nil, email: nil, phoneNumber: newPhoneNumber)).responseJSON { (request, response, JSON, error) in
        if let error = error {
          displayAPIErrorToUser(JSON)
          error.print("add phone number to new user")
          self.topBar.spinRightButton(false)
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
