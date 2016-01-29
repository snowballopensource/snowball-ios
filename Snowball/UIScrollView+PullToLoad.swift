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

  private struct AssociatedKeys {
    static var pullToLoadStateKey = "pullToLoadState"
    static var pullToLoadDelegateKey = "pullToLoadDelegate"
  }

  private(set) var pullToLoadState: UIScrollViewPullToLoadState {
    get {
      return UIScrollViewPullToLoadState(rawValue: objc_getAssociatedObject(self, &AssociatedKeys.pullToLoadStateKey) as? Int ?? UIScrollViewPullToLoadState.Default.rawValue)!
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.pullToLoadStateKey, newValue.rawValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private var pullToLoadDelegate: UIScrollViewPullToLoadDelegate? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.pullToLoadDelegateKey) as? UIScrollViewPullToLoadDelegate
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.pullToLoadDelegateKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_ASSIGN)
    }
  }

  // MARK: Internal

  func enablePullToLoadWithDelegate(delegate: UIScrollViewPullToLoadDelegate) {
    pullToLoadDelegate = delegate
    addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
  }

  func disablePullToLoad() {
    removeObserver(self, forKeyPath: "contentOffset")
  }

  func stopPullToLoadAnimation() {
    pullToLoadState = .Default
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
    if pullToLoadState != .Loading {
      if pullToLoadState == .Triggered && !dragging {
        pullToLoadState = .Loading
        pullToLoadDelegate?.scrollViewDidPullToLoad(self)
      } else if contentOffset.x < scrollThreshold && pullToLoadState == .Default && dragging {
        pullToLoadState = .Triggered
      } else if contentOffset.x >= scrollThreshold && pullToLoadState != .Default {
        pullToLoadState = .Default
      }
    }
  }
}

// MARK: - UIScrollViewPullToLoadState
enum UIScrollViewPullToLoadState: Int {
  case Default, Triggered, Loading
}

// MARK: - UIScrollViewPullToLoadDelegate
protocol UIScrollViewPullToLoadDelegate: class {
  func scrollViewDidPullToLoad(scrollView: UIScrollView)
}