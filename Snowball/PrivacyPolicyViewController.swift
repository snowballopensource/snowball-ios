//
//  PrivacyPolicyViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/23/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class PrivacyPolicyViewController: WebViewController {

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    topView.titleLabel.text = NSLocalizedString("Privacy Policy")

    let request = NSURLRequest(URL: NSURL(string: "http://snowball.is/privacy")!)
    webView.loadRequest(request)
  }
}
