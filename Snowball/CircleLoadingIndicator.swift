//
//  CircleLoadingIndicator.swift
//  Snowball
//
//  Created by James Martinez on 9/9/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class CircleLoadingIndicator: UIView {

  // MARK: - UIView

  convenience init() {
    self.init(frame: CGRectZero)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.cornerRadius = frame.size.width/2
  }

  // MARK: - Internal

  func startAnimating() {
    backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0)
    hidden = false
    UIView.animateWithDuration(0.1, delay: 1, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
      self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.2)
    }) { (completed) -> Void in
      if completed {
        UIView.animateWithDuration(1, delay: 0, options: UIViewAnimationOptions.CurveLinear | UIViewAnimationOptions.Autoreverse | UIViewAnimationOptions.Repeat, animations: { () -> Void in
          self.backgroundColor = UIColor.whiteColor().colorWithAlphaComponent(0.9)
          }, completion: nil)
      }
    }
  }

  func stopAnimating() {
    layer.removeAllAnimations()
    hidden = true
  }
}