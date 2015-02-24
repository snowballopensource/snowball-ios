//
//  WebViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/23/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class WebViewController: UIViewController {

  // MARK: - Properties

  let topView = SnowballTopView(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: nil)
  let webView = UIWebView()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    view.addSubview(topView)
    topView.setupDefaultLayout()

    view.addSubview(webView)
    layout(webView, topView) { (webView, topView) in
      webView.left == webView.superview!.left
      webView.top == topView.bottom
      webView.right == webView.superview!.right
      webView.bottom == webView.superview!.bottom
    }
  }
}

// MARK: -

extension WebViewController: SnowballTopViewDelegate {

  // MARK: - SnowballTopViewDelegate

  func snowballTopViewLeftButtonTapped() {
    navigationController?.popViewControllerAnimated(true)
  }

}