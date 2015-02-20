//
//  OnboardingPageViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/19/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class OnboardingPageViewController: UIViewController {

  // MARK: - Properties

  let pageViewController = UIPageViewController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll, navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal, options: nil)

  let viewControllerClasses: [UIViewController.Type] = [OnboardingPlayViewController.self, OnboardingCaptureViewController.self, OnboardingAddViewController.self]

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    pageViewController.dataSource = self

    pageViewController.setViewControllers([viewControllerAtIndex(0)!], direction: UIPageViewControllerNavigationDirection.Forward, animated: false, completion: nil)

    addChildViewController(pageViewController)
    pageViewController.view.frame = view.bounds
    view.addSubview(pageViewController.view)
    pageViewController.didMoveToParentViewController(self)
  }

  // MARK: - Internal

  func indexOfViewControllerClass(viewControllerClass: UIViewController.Type) -> Int {
    for i in (0..<viewControllerClasses.count) {
      if NSStringFromClass(viewControllerClasses[i]) == NSStringFromClass(viewControllerClass) {
        return i
      }
    }
    return 0
  }

  func viewControllerAtIndex(index: Int) -> UIViewController? {
    if index >= viewControllerClasses.count || index < 0 {
      return nil
    }
    let viewControllerClass = viewControllerClasses[index]
    return viewControllerClass()
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

  func presentationIndexForPageViewController(pageViewController: UIPageViewController) -> Int {
    return 0
  }

  func presentationCountForPageViewController(pageViewController: UIPageViewController) -> Int {
    return viewControllerClasses.count
  }

}