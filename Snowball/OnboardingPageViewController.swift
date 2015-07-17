//
//  OnboardingPageViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/19/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class OnboardingPageViewController: UIViewController {

  // MARK: - Properties

  private let pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)

  private let pageControl: UIPageControl = {
    let pageControl = UIPageControl()
    pageControl.currentPage = 0
    pageControl.pageIndicatorTintColor = UIColor.SnowballColor.grayColor
    pageControl.currentPageIndicatorTintColor = UIColor.SnowballColor.blueColor
    return pageControl
  }()

  private let viewControllerClasses: [UIViewController.Type] = [OnboardingIntroViewController.self, OnboardingPlayViewController.self, OnboardingCaptureViewController.self, OnboardingAddViewController.self, OnboardingConnectViewController.self]

  private let tapGestureRecognizer = UITapGestureRecognizer()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor.whiteColor()

    pageViewController.dataSource = self
    pageViewController.delegate = self
    pageViewController.setViewControllers([viewControllerAtIndex(0)!], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

    addChildViewController(pageViewController)
    pageViewController.view.frame = view.bounds
    view.addSubview(pageViewController.view)
    pageViewController.didMoveToParentViewController(self)

    pageControl.numberOfPages = viewControllerClasses.count
    view.addSubview(pageControl)
    layout(pageControl) { (pageControl) in
      pageControl.centerX == pageControl.superview!.centerX
      pageControl.top == pageControl.superview!.top + 20
      return
    }

    tapGestureRecognizer.addTarget(self, action: "tapGestureRecognizerTapped")
    view.addGestureRecognizer(tapGestureRecognizer)
  }

  // MARK: - Private

  private func indexOfViewControllerClass(viewControllerClass: UIViewController.Type) -> Int {
    for i in (0..<viewControllerClasses.count) {
      if NSStringFromClass(viewControllerClasses[i]) == NSStringFromClass(viewControllerClass) {
        return i
      }
    }
    return 0
  }

  private func viewControllerAtIndex(index: Int) -> UIViewController? {
    if index >= viewControllerClasses.count || index < 0 {
      return nil
    }
    let viewControllerClass = viewControllerClasses[index]
    return viewControllerClass()
  }

  @objc private func tapGestureRecognizerTapped() {
    if let viewController = pageViewController.viewControllers.last as? UIViewController {
      if let nextViewController = pageViewController(pageViewController, viewControllerAfterViewController: viewController) {
        let viewControllers = [nextViewController]
        // Have to call the willTransitionToViewControllers manually since the delegate
        // is not called when navigating programatically...
        pageViewController(pageViewController, willTransitionToViewControllers: viewControllers)
        pageViewController.setViewControllers(viewControllers, direction: UIPageViewControllerNavigationDirection.Forward, animated: true, completion: nil)
      }
    }
  }
}

// MARK: -

extension OnboardingPageViewController: UIPageViewControllerDataSource {

  // MARK: - UIPageViewControllerDataSource

  func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
    let index = indexOfViewControllerClass(viewController.dynamicType)
    return viewControllerAtIndex(index - 1)
  }

  func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
    let index = indexOfViewControllerClass(viewController.dynamicType)
    return viewControllerAtIndex(index + 1)
  }
}

// MARK: -

extension OnboardingPageViewController: UIPageViewControllerDelegate {

  // MARK: - UIPageViewControllerDelegate

  func pageViewController(pageViewController: UIPageViewController, willTransitionToViewControllers pendingViewControllers: [AnyObject]) {
    if let nextVC = pendingViewControllers.first as? UIViewController {
      pageControl.currentPage = indexOfViewControllerClass(nextVC.dynamicType)
    }
  }
}