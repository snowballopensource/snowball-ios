//
//  UIView+.swift
//  Snowball
//
//  Created by James Martinez on 9/24/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIView {

  func addFullViewSubview(view: UIView) {
    prepareFullScreenSubview(view)
    addSubview(view)
  }

  func insertFullViewSubview(view: UIView, belowSubview siblingSubview: UIView) {
    prepareFullScreenSubview(view)
    insertSubview(view, belowSubview: siblingSubview)
  }

  private func prepareFullScreenSubview(view: UIView) {
    view.frame = frame
    view.autoresizingMask = UIViewAutoresizing.FlexibleHeight | UIViewAutoresizing.FlexibleWidth
  }

}