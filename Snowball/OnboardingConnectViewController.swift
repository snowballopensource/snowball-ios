//
//  OnboardingConnectViewController.swift
//  Snowball
//
//  Created by James Martinez on 7/10/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class OnboardingConnectViewController: OnboardingViewController {

  // MARK: - Properties

  let doneButton: UIButton = {
    let button = UIButton()
    button.setTitle(NSLocalizedString("Done", comment: ""), forState: UIControlState.Normal)
    button.setTitleColor(UIColor.SnowballColor.blueColor, forState: UIControlState.Normal)
    button.titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 22)
    return button
    }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = NSLocalizedString("Connect", comment: "")
    detailImageView.image = UIImage(named: "onboard-connect")

    doneButton.addTarget(self, action: "doneButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    view.addSubview(doneButton)
    layout(doneButton) { (doneButton) in
      let margin: Float = 10
      doneButton.right == doneButton.superview!.right - margin
      doneButton.top == doneButton.superview!.top + margin
      doneButton.width == 80
      doneButton.height == 44
    }
  }

  // MARK: - Private

  @objc private func doneButtonTapped() {
    Analytics.track("Finish Onboarding")
    dismissViewControllerAnimated(true, completion: nil)
  }
  
}