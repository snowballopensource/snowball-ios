//
//  OnboardingPlayViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/19/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class OnboardingPlayViewController: OnboardingViewController {

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = NSLocalizedString("Play")
    detailLabel.text = NSLocalizedString("Tap on a clip in the timeline to start playing from there.\n\nTap again to stop.")
    detailImageView.image = UIImage(named: "onboarding-play")
  }

}