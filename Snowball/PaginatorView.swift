//
//  PaginatorView.swift
//  Snowball
//
//  Created by James Martinez on 8/26/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

class PaginatorView: UIView {

  // MARK: Properties

  var state = PaginatorState.Default

  private(set) var threshold: CGFloat

  // MARK: Initializers

  init(size: CGFloat) {
    threshold = size
    super.init(frame: CGRectZero)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
