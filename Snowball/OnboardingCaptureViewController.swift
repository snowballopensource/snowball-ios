//
//  OnboardingCaptureViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/19/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class OnboardingCaptureViewController: OnboardingViewController {

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = NSLocalizedString("Capture")
    detailLabel.text = NSLocalizedString("Simply tap-and-hold in the camera view to capture a clip.")
    detailImageView.image = UIImage(named: "onboarding-capture")
  }

}