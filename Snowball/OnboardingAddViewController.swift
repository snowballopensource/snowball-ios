//
//  OnboardingAddViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/19/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class OnboardingAddViewController: UIViewController {

  // MARK: - Properties

  let doneButton: UIButton = {
    let doneButton = UIButton()
    doneButton.setTitle(NSLocalizedString("Done"), forState: UIControlState.Normal)
    doneButton.setTitleColor(UIColor.SnowballColor.greenColor, forState: UIControlState.Normal)
    doneButton.titleLabel?.font = UIFont(name: UIFont.SnowballFont.regular, size: 24)
    return doneButton
  }()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

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
    dismissViewControllerAnimated(true, completion: nil)
  }

}