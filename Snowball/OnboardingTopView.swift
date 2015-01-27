//
//  OnboardingTopView.swift
//  Snowball
//
//  Created by James Martinez on 1/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class OnboardingTopView: SnowballTopView {
  let pageControl = UIPageControl()

  // MARK: - UIView

  convenience override init() {
    self.init(leftButtonType: SnowballTopViewButtonType.Back, rightButtonType: SnowballTopViewButtonType.Forward)

    pageControl.numberOfPages = 3
    pageControl.currentPage = 0
    pageControl.pageIndicatorTintColor = UIColor.SnowballColor.greenColor.colorWithAlphaComponent(0.3)
    pageControl.currentPageIndicatorTintColor = UIColor.SnowballColor.greenColor
    addSubview(pageControl)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    pageControl.center = center
  }

  // MARK: - Public

  func setPage(page: Int) {
    pageControl.currentPage = page
  }
}