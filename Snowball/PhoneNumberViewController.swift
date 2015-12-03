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
    label.text = NSLocalizedString("Next we need your phone number so we can help you find your friends.", comment: "")
    return label
  }()

  private let countryCodeDescriptionLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 14)
    label.text = NSLocalizedString("Country", comment: "")
    return label
  }()

  private let countryCodeTextField: SnowballRoundedTextField = {
    let textField = SnowballRoundedTextField()
    textField.layer.borderWidth = 2
    textField.layer.borderColor = UIColor.blackColor().CGColor
    textField.layer.cornerRadius = 10
    textField.keyboardType = UIKeyboardType.PhonePad
    textField.text = "+1"
    textField.font = UIFont(name: "Helvetica", size: 24)
    textField.textAlignment = NSTextAlignment.Center
    textField.tintColor = UIColor.blackColor()
    return textField
  }()

  private let phoneNumberDescriptionLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont(name: UIFont.SnowballFont.regular, size: 14)
    label.text = NSLocalizedString("Number", comment: "")
    return label
  }()

  private let phoneNumberTextField: SnowballRoundedTextField = {
    let textField = SnowballRoundedTextField()
    textField.keyboardType = UIKeyboardType.PhonePad
    textField.attributedPlaceholder = NSAttributedString(string: "4151234567", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor])
    textField.font = UIFont(name: "Helvetica", size: 28)
    textField.tintColor = UIColor.SnowballColor.blueColor
    return textField
  }()

  private let phoneNumberTextFieldBottomBorderLine: UIView = {
    let view = UIView()
    view.backgroundColor = UIColor.blackColor()
    return view
  }()

  private let continueButton: SnowballRoundedButton = {
    let button = SnowballRoundedButton(style: .Rainbow)
    button.setTitle(NSLocalizedString("continue", comment: ""), forState: UIControlState.Normal)
    return button
  }()

  private let disclaimerLabel: UILabel = {
    let label = UILabel()
    label.text = NSLocalizedString("No one will ever see your phone number on Snowball.", comment: "")
    label.font = UIFont(name: UIFont.SnowballFont.bold, size: 10)
    return label
  }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topBar)
    topBar.setupDefaultLayout()

    view.addSubview(messageLabel)
    constrain(messageLabel, topBar) { (messageLabel, topBar) in
      let sideMargin: CGFloat = 25
      messageLabel.left == messageLabel.superview!.left + sideMargin
      messageLabel.top == topBar.bottom
      messageLabel.right == messageLabel.superview!.right - sideMargin
    }

    view.addSubview(countryCodeDescriptionLabel)
    constrain(countryCodeDescriptionLabel, messageLabel) { (countryCodeDescriptionLabel, messageLabel) in
      countryCodeDescriptionLabel.left == countryCodeDescriptionLabel.superview!.left + 25
      countryCodeDescriptionLabel.top == messageLabel.bottom + 15
    }

    countryCodeTextField.delegate = self
    view.addSubview(countryCodeTextField)
    constrain(countryCodeTextField, countryCodeDescriptionLabel) { (countryCodeTextField, countryCodeDescriptionLabel) in
      countryCodeTextField.left == countryCodeTextField.superview!.left + 25
      countryCodeTextField.top == countryCodeDescriptionLabel.bottom + 15
      countryCodeTextField.width == 80
      countryCodeTextField.height == 50
    }

    view.addSubview(phoneNumberDescriptionLabel)
    constrain(phoneNumberDescriptionLabel, countryCodeDescriptionLabel, countryCodeTextField) { (phoneNumberDescriptionLabel, countryCodeDescriptionLabel, countryCodeTextField) in
      phoneNumberDescriptionLabel.left == countryCodeTextField.right + 20
      phoneNumberDescriptionLabel.top == countryCodeDescriptionLabel.top
    }

    view.addSubview(phoneNumberTextField)
    constrain(phoneNumberTextField, phoneNumberDescriptionLabel) { (phoneNumberTextField, phoneNumberDescriptionLabel) in
      phoneNumberTextField.left == phoneNumberDescriptionLabel.left
      phoneNumberTextField.top == phoneNumberDescriptionLabel.bottom + 15
      phoneNumberTextField.right == phoneNumberTextField.superview!.right - 25
      phoneNumberTextField.height == 50
    }

    view.addSubview(phoneNumberTextFieldBottomBorderLine)
    constrain(phoneNumberTextFieldBottomBorderLine, phoneNumberTextField) { bottomBorderLine, phoneNumberTextField in
      bottomBorderLine.left == phoneNumberTextField.left
      bottomBorderLine.bottom == phoneNumberTextField.bottom - 1
      bottomBorderLine.right == phoneNumberTextField.right
      bottomBorderLine.height == 1
    }

    view.addSubview(continueButton)
    constrain(continueButton, phoneNumberTextFieldBottomBorderLine) { continueButton, phoneNumberTextFieldBottomBorderLine in
      continueButton.left == continueButton.superview!.left + 25
      continueButton.top == phoneNumberTextFieldBottomBorderLine.bottom + 25
      continueButton.right == continueButton.superview!.right - 25
    }

    view.addSubview(disclaimerLabel)
    constrain(disclaimerLabel, continueButton) { (disclaimerLabel, continueButton) in
      disclaimerLabel.centerX == disclaimerLabel.superview!.centerX
      disclaimerLabel.top == continueButton.bottom + 30
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
      SnowballAPI.request(.UpdateCurrentUser(name: nil, username: nil, email: nil, phoneNumber: newPhoneNumber)) { response in
        self.topBar.spinRightButton(false)
        switch response {
        case .Success:
          Analytics.track("Add Phone Number During Onboarding")
          self.dismissViewControllerAnimated(true, completion: nil)
        case .Failure(let error):
          if let alertController = error.newAlertViewController() {
            self.presentViewController(alertController, animated: true, completion: nil)
          }
        }
      }
    } else {
      dismissViewControllerAnimated(true, completion: nil)
    }
  }
}

// MARK: -
extension PhoneNumberViewController: UITextFieldDelegate {
  func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
    if textField == countryCodeTextField {
      let resultString = (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string) as NSString
      let prefixString = "+"
      let prefixStringRange = resultString.rangeOfString(prefixString)
      if prefixStringRange.location != 0 {
        return false
      }
    }
    return true
  }
}