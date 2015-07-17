//
//  OnboardingCaptureViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/19/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class OnboardingCaptureViewController: OnboardingViewController {

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = NSLocalizedString("Capture", comment: "")
    detailImageView.image = UIImage(named: "onboard-capture")
  }

}