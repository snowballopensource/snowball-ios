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

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.cornerRadius = frame.size.width/2
  }

  // MARK: - Internal

  func startAnimating(color: UIColor = UIColor.whiteColor(), withDelay delay: Bool = false) {
    if delay {
      backgroundColor = color.colorWithAlphaComponent(0)
      hidden = false
      UIView.animateWithDuration(0.1, delay: 1, options: UIViewAnimationOptions.CurveLinear, animations: { () -> Void in
        self.backgroundColor = color.colorWithAlphaComponent(0.2)
        }) { (completed) -> Void in
          if completed {
            self.startPulseAnimation(color: color)
          }
      }
    } else {
      backgroundColor = color.colorWithAlphaComponent(0.2)
      hidden = false
      startPulseAnimation(color: color)
    }
  }

  func stopAnimating() {
    layer.removeAllAnimations()
    hidden = true
  }

  // MARK: - Private

  private func startPulseAnimation(color color: UIColor) {
    backgroundColor = color.colorWithAlphaComponent(0.2)
    UIView.animateWithDuration(1, delay: 0, options: [UIViewAnimationOptions.CurveLinear, UIViewAnimationOptions.Autoreverse, UIViewAnimationOptions.Repeat], animations: { () -> Void in
      self.backgroundColor = color.colorWithAlphaComponent(0.9)
      }, completion: nil)
  }
}