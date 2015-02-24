//
//  TermsViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/23/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class TermsViewController: WebViewController {

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    topView.titleLabel.text = NSLocalizedString("Terms of Service")

    let request = NSURLRequest(URL: NSURL(string: "http://snowball.is/terms")!)
    webView.loadRequest(request)
  }
}
