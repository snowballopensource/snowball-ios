//
//  OnboardingAddViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/19/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class OnboardingAddViewController: OnboardingViewController {

  // MARK: - Properties

  let doneButton: UIButton = {
    let button = UIButton()
    button.setTitle(NSLocalizedString("Done", comment: ""), forState: UIControlState.Normal)
    button.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
    button.titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 22)
    return button
  }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    titleLabel.text = NSLocalizedString("Add", comment: "")
    detailLabel.text = NSLocalizedString("Just tap + to add your clip to the timeline.\n\nNow your friends will see it in their film.", comment: "")
    detailImageView.image = UIImage(named: "onboarding-add")

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