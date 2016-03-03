//
//  PulsingLoadingIndicatorView.swift
//  Snowball
//
//  Created by James Martinez on 3/2/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

class PulsingLoadingIndicatorView: UIView {

  // MARK: Properties

  static let defaultRadius: CGFloat = 15

  // MARK: UIView

  convenience init() {
    self.init(frame: CGRectZero)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    hidden = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.cornerRadius = frame.size.width / 2
  }

  // MARK: Internal

  func startAnimating(color: UIColor = UIColor.whiteColor(), withDelay delay: Bool = true) {
    if delay {
      backgroundColor = color.colorWithAlphaComponent(0)
      hidden = false
      UIView.animateWithDuration(0.1,
        delay: 1,
        options: .CurveLinear,
        animations: {
          self.backgroundColor = color.colorWithAlphaComponent(0.2)
        },
        completion: { finished in
          if finished {
            self.startPulseAnimation(color: color)
          }
      })
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

  // MARK: Private

  private func startPulseAnimation(color color: UIColor) {
    backgroundColor = color.colorWithAlphaComponent(0.2)
    UIView.animateWithDuration(1,
      delay: 0,
      options: [.CurveLinear, .Autoreverse, .Repeat],
      animations: { () -> Void in
        self.backgroundColor = color.colorWithAlphaComponent(0.9)
      },
      completion: nil)
  }
}
