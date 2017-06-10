//
//  UIScrollView+PullToLoad.swift
//  Snowball
//
//  Created by James Martinez on 1/28/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit


extension UIScrollView {

  // MARK: Properties

  fileprivate struct AssociatedKeys {
    static var pullToLoadStateKey = "pullToLoadState"
    static var pullToLoadDelegateKey = "pullToLoadDelegate"
  }

  fileprivate(set) var pullToLoadState: UIScrollViewPullToLoadState {
    get {
      return UIScrollViewPullToLoadState(rawValue: objc_getAssociatedObject(self, &AssociatedKeys.pullToLoadStateKey) as? Int ?? UIScrollViewPullToLoadState.default.rawValue)!
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.pullToLoadStateKey, newValue.rawValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  fileprivate var pullToLoadDelegate: UIScrollViewPullToLoadDelegate? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.pullToLoadDelegateKey) as? UIScrollViewPullToLoadDelegate
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.pullToLoadDelegateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
  }

  // MARK: Internal

  func enablePullToLoadWithDelegate(_ delegate: UIScrollViewPullToLoadDelegate) {
    pullToLoadDelegate = delegate
    addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.new, context: nil)
  }

  func disablePullToLoad() {
    removeObserver(self, forKeyPath: "contentOffset")
  }

  func stopPullToLoadAnimation() {
    pullToLoadState = .default
  }

  // MARK: KVO

  open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    if keyPath == "contentOffset" {
      guard let contentOffset = (change?[NSKeyValueChangeKey.newKey] as AnyObject).cgPointValue else { return }
      scrollViewDidScrollToContentOffset(contentOffset)
    }
  }

  // MARK: Private

  // This method only supports horizontal scrolling (e.g. the timeline). Convert to vertical and add an option for that if support is desired.
  fileprivate func scrollViewDidScrollToContentOffset(_ contentOffset: CGPoint) {
    let scrollThreshold: CGFloat = -60
    if pullToLoadState != .loading {
      if pullToLoadState == .triggered && !isDragging {
        pullToLoadState = .loading
        pullToLoadDelegate?.scrollViewDidPullToLoad(self)
      } else if contentOffset.x < scrollThreshold && pullToLoadState == .default && isDragging {
        pullToLoadState = .triggered
      } else if contentOffset.x >= scrollThreshold && pullToLoadState != .default {
        pullToLoadState = .default
      }
    }
  }
}

// MARK: - UIScrollViewPullToLoadState
enum UIScrollViewPullToLoadState: Int {
  case `default`, triggered, loading
}

// MARK: - UIScrollViewPullToLoadDelegate
protocol UIScrollViewPullToLoadDelegate: class {
  func scrollViewDidPullToLoad(_ scrollView: UIScrollView)
}
