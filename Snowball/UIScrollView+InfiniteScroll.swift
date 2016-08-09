//
//  UIScrollView+InfiniteScroll.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIScrollView {

  // MARK: Properties

  private struct AssociatedKeys {
    static var infiniteScrollStateKey = "infiniteScrollState"
    static var infiniteScrollThresholds = "infiniteScrollThresholds"
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

  private var infiniteScrollThresholds: UIScrollViewInfiniteScrollThresholds? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.infiniteScrollThresholds) as? UIScrollViewInfiniteScrollThresholds
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.infiniteScrollThresholds, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
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

  func enableInfiniteScrollWithDelegate(delegate: UIScrollViewInfiniteScrollDelegate) {
    enableInfiniteScrollWithDelegate(delegate, thresholds: UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0))
  }

  func enableInfiniteScrollWithDelegate(delegate: UIScrollViewInfiniteScrollDelegate, thresholds: UIEdgeInsets) {
    infiniteScrollDelegate = delegate
    infiniteScrollThresholds = UIScrollViewInfiniteScrollThresholds(insets: thresholds)
    addObserver(self, forKeyPath: "contentOffset", options: NSKeyValueObservingOptions.New, context: nil)
  }

  func disableInfiniteScroll() {
    removeObserver(self, forKeyPath: "contentOffset")
  }

  func setLoadingCompleted() {
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

  private func scrollViewDidScrollToContentOffset(contentOffset: CGPoint) {
    guard infiniteScrollState != .Loading else { return }
    guard let thresholds = infiniteScrollThresholds else { return }

    var direction: UIScrollViewInfiniteScrollDirection?
    if contentOffset.x < thresholds.left {
      direction = .Left
    } else if contentOffset.y < thresholds.top {
      direction = .Top
    } else if contentOffset.x > contentSize.width - bounds.width - thresholds.right {
      direction = .Right
    } else if contentOffset.y > contentSize.height - bounds.height - thresholds.bottom {
      direction = .Bottom
    }

    if let direction = direction {
      if infiniteScrollState == .Triggered && !dragging {
        infiniteScrollState = .Loading
        infiniteScrollDelegate?.scrollView(self, infiniteScrollTriggered: direction)
      } else if infiniteScrollState == .Default && dragging {
        infiniteScrollState = .Triggered
      } else if infiniteScrollState != .Default {
        infiniteScrollState = .Default
      }
    }
  }
}

// MARK: - UIScrollViewInfiniteScrollThresholds
class UIScrollViewInfiniteScrollThresholds {
  let insets: UIEdgeInsets

  var left: CGFloat { return insets.left }
  var top: CGFloat { return insets.top }
  var right: CGFloat { return insets.right }
  var bottom: CGFloat { return insets.bottom }

  init(insets: UIEdgeInsets) {
    self.insets = insets
  }
}

// MARK: - UIScrollViewInfiniteScrollState
enum UIScrollViewInfiniteScrollState: Int {
  case Default, Triggered, Loading
}

// MARK: - UIScrollViewInfiniteScrollDirection
enum UIScrollViewInfiniteScrollDirection {
  case Left, Top, Right, Bottom
}

// MARK: - UIScrollViewInfiniteScrollDelegate
protocol UIScrollViewInfiniteScrollDelegate: class {
  func scrollView(scrollView: UIScrollView, infiniteScrollTriggered direction: UIScrollViewInfiniteScrollDirection)
}