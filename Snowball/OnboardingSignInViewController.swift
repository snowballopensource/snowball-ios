//
//  OnboardingSignInViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class OnboardingSignInViewController: OnboardingAuthenticationViewController {

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    let messageStringOne = NSAttributedString(string: "Ok, let's get you ", attributes: [NSForegroundColorAttributeName: UIColor.blackColor()])
    let messageStringTwo = NSAttributedString(string: "back into\n", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.greenColor])
    let messageStringThree = NSAttributedString(string: "your account.", attributes: [NSForegroundColorAttributeName: UIColor.SnowballColor.grayColor])
    let messageString = NSMutableAttributedString(attributedString: messageStringOne)
    messageString.appendAttributedString(messageStringTwo)
    messageString.appendAttributedString(messageStringThree)
    messageLabel.attributedText = messageString
  }

  // MARK: - OnboardingAuthenticationViewController

  override func goForward() {
    if validateFields() {
      println("sign in")
    }
  }
}