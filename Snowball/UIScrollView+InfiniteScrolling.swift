//
//  UIScrollView+InfiniteScrolling.swift
//  Snowball
//
//  Created by James Martinez on 1/28/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit


extension UIScrollView {

  // MARK: Properties

  private struct AssociatedKeys {
    static var infiniteScrollStateKey = "infiniteScrollState"
    static var infiniteScrollDelegateKey = "infiniteScrollDelegate"
  }

  private(set) var infiniteScrollState: UIScrollViewInfiniteScrollState {
    get {
      return UIScrollViewInfiniteScrollState(rawValue: objc_getAssociatedObject(self, &AssociatedKeys.infiniteScrollStateKey) as? Int ?? UIScrollViewInfiniteScrollState.Default.rawValue)!
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.infiniteScrollStateKey, newValue.rawValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private var infiniteScrollDelegate: UIScrollViewInfiniteScrollDelegate? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.infiniteScrollDelegateKey) as? UIScrollViewInfiniteScrollDelegate
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.infiniteScrollDelegateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
  }

  // MARK: Internal

  func enableInfiniteScrollingWithDelegate(delegate: UIScrollViewInfiniteScrollDelegate) {
    infiniteScrollDelegate = delegate
    addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
  }

  func disableInfiniteScrolling() {
    removeObserver(self, forKeyPath: "contentOffset")
  }

  func stopInfiniteScrollAnimation() {
    infiniteScrollState = .Default
  }

  // MARK: KVO

  public override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    if keyPath == "contentOffset" {
      guard let contentOffset = change?[NSKeyValueChangeNewKey]?.CGPointValue else { return }
      scrollViewDidScrollToContentOffset(contentOffset)
    }
  }

  // MARK: Private

  // This method only supports horizontal scrolling (e.g. the timeline). Convert to vertical and add an option for that if support is desired.
  private func scrollViewDidScrollToContentOffset(contentOffset: CGPoint) {
    let scrollThreshold: CGFloat = -60
    if infiniteScrollState != .Loading {
      if infiniteScrollState == .Triggered && !dragging {
        infiniteScrollState = .Loading
        infiniteScrollDelegate?.scrollViewDidPullToRefresh(self)
      } else if contentOffset.x < scrollThreshold && infiniteScrollState == .Default && dragging {
        infiniteScrollState = .Triggered
      } else if contentOffset.x >= scrollThreshold && infiniteScrollState != .Default {
        infiniteScrollState = .Default
      }
    }
  }
}

// MARK: - UIScrollViewInfiniteScrollState
enum UIScrollViewInfiniteScrollState: Int {
  case Default, Triggered, Loading
}

// MARK: - UIScrollViewInfiniteScrollDelegate
protocol UIScrollViewInfiniteScrollDelegate: class {
  func scrollViewDidPullToRefresh(scrollView: UIScrollView)
}