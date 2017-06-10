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
    self.init(frame: CGRect.zero)
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    clipsToBounds = true
    isHidden = true
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override func layoutSubviews() {
    super.layoutSubviews()

    layer.cornerRadius = frame.size.width / 2
  }

  // MARK: Internal

  func startAnimating(_ color: UIColor = UIColor.white, withDelay delay: Bool = true) {
    if delay {
      backgroundColor = color.withAlphaComponent(0)
      isHidden = false
      UIView.animate(withDuration: 0.1,
        delay: 1,
        options: .curveLinear,
        animations: {
          self.backgroundColor = color.withAlphaComponent(0.2)
        },
        completion: { finished in
          if finished {
            self.startPulseAnimation(color: color)
          }
      })
    } else {
      backgroundColor = color.withAlphaComponent(0.2)
      isHidden = false
      startPulseAnimation(color: color)
    }
  }

  func stopAnimating() {
    layer.removeAllAnimations()
    isHidden = true
  }

  // MARK: Private

  fileprivate func startPulseAnimation(color: UIColor) {
    backgroundColor = color.withAlphaComponent(0.2)
    UIView.animate(withDuration: 1,
      delay: 0,
      options: [.curveLinear, .autoreverse, .repeat],
      animations: { () -> Void in
        self.backgroundColor = color.withAlphaComponent(0.9)
      },
      completion: nil)
  }
}
