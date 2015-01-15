//
//  OnboardingSignUpViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class OnboardingSignUpViewController: OnboardingAuthenticationViewController {

  // MARK: - OnboardingAuthenticationViewController

  override func goForward() {
    if validateFields() {
      println("sign up")
    }
  }
}