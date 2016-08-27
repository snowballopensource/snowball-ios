//
//  Paginator.swift
//  Snowball
//
//  Created by James Martinez on 8/26/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

class Paginator: NSObject {

  // MARK: Properties

  let position: PaginatorPosition
  let view: PaginatorView

  private(set) var state = PaginatorState.Default {
    didSet {
      if oldValue != state {
        setInsetsForStateAnimated(state)
        view.state = state

        if state == .Loading {
          self.loadBlock()
        }
      }
    }
  }

  var _scrollView: UIScrollView? {
    didSet {
      if _scrollView == nil {
        _scrollView?.removeObserver(self, forKeyPath: "contentOffset")
        _scrollView?.removeObserver(self, forKeyPath: "contentSize")
      } else {
        _scrollView?.addObserver(self, forKeyPath: "contentOffset", options: .Initial, context: nil)
        _scrollView?.addObserver(self, forKeyPath: "contentSize", options: .Initial, context: nil)
      }
    }
  }

  let loadBlock: () -> Void

  // MARK: Initializers

  init(postition: PaginatorPosition, view: PaginatorView, loadBlock: () -> Void) {
    self.position = postition
    self.view = view
    self.loadBlock = loadBlock

    view.hidden = true
  }

  // MARK: KVO

  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    guard let scrollView = _scrollView else { return }

    if keyPath == "contentOffset" {
      var offset: CGFloat
      switch position {
      case .Left:
        offset = -scrollView.contentOffset.x
      case .Top:
        offset = -scrollView.contentOffset.y
      case .Right:
        offset = scrollView.contentOffset.x + scrollView.frame.width - scrollView.contentSize.width
      case .Bottom:
        offset = scrollView.contentOffset.y + scrollView.frame.height - scrollView.contentSize.height
      }
      setStateForOffset(offset)

    } else if keyPath == "contentSize" {
      if let leftPaginator = scrollView.leftPaginator {
        let size = leftPaginator.view.threshold
        leftPaginator.view.frame = CGRect(x: -size, y: 0, width: size, height: scrollView.bounds.height)
        leftPaginator.view.hidden = (scrollView.contentSize.width == 0)
      }
      if let topPaginator = scrollView.topPaginator {
        let size = topPaginator.view.threshold
        topPaginator.view.frame = CGRect(x: 0, y: -size, width: scrollView.bounds.width, height: size)
        topPaginator.view.hidden = (scrollView.contentSize.height == 0)
      }
      if let rightPaginator = scrollView.rightPaginator {
        let size = rightPaginator.view.threshold
        rightPaginator.view.frame = CGRect(x: scrollView.contentSize.width, y: 0, width: size, height: scrollView.bounds.height)
        rightPaginator.view.hidden = (scrollView.contentSize.width == 0)
      }
      if let bottomPaginator = scrollView.bottomPaginator {
        let size = bottomPaginator.view.threshold
        bottomPaginator.view.frame = CGRect(x: 0, y: scrollView.contentSize.height, width: scrollView.bounds.width, height: size)
        bottomPaginator.view.hidden = (scrollView.contentSize.height == 0)
      }
    }
  }

  // MARK: Internal

  func beginLoading() {
    state = .Loading
  }

  func endLoading() {
    state = .Default
  }

  // MARK: Private

  private func offsetPercentageForOffset(offset: CGFloat) -> Float {
    if view.threshold == 0 { return 0 }

    var offsetPercentage = Float(offset / view.threshold * 100)
    if offsetPercentage <= 0 {
      offsetPercentage = 0
    } else if offsetPercentage > 100 {
      offsetPercentage = 100
    }
    return offsetPercentage
  }

  private func setStateForOffset(offset: CGFloat) {
    guard let scrollView = _scrollView else { return }

    let offsetPercentage = offsetPercentageForOffset(offset)

    switch state {
    case .Default:
      if offsetPercentage > 0 && scrollView.dragging { state = .InMotion(progress: offsetPercentage) }
    case .InMotion:
      if offsetPercentage >= 0 && (scrollView.dragging || scrollView.decelerating) { state = .InMotion(progress: offsetPercentage) }
      if offsetPercentage == 0 && !scrollView.dragging { state = .Default }
      if offsetPercentage == 100 && !scrollView.dragging { state = .Loading }
    default: break
    }
  }

  private func setInsetsForStateAnimated(state: PaginatorState) {
    guard let scrollView = _scrollView else { return }

    func performAnimated(block: () -> Void) {
      UIView.animateWithDuration(0.3) {
        block()
      }
    }

    if state == .Loading {
      performAnimated {
        switch self.position {
        case .Left:
          scrollView.contentInset.left = self.view.threshold
        case .Top:
          scrollView.contentInset.top = self.view.threshold
        case .Right:
          scrollView.contentInset.right = self.view.threshold
        case .Bottom:
          scrollView.contentInset.bottom = self.view.threshold
        }
      }
    } else if state == .Default {
      performAnimated {
        switch self.position {
        case .Left:
          scrollView.contentInset.left = 0
        case .Top:
          scrollView.contentInset.top = 0
        case .Right:
          scrollView.contentInset.right = 0
        case .Bottom:
          scrollView.contentInset.bottom = 0
        }
      }
    }
  }
}

// MARK: - PaginatorPosition
enum PaginatorPosition {
  case Left, Top, Right, Bottom
}

// MARK: - PaginatorState
enum PaginatorState {
  case Default, InMotion(progress: Float), Loading
}

extension PaginatorState: Equatable {}
func ==(lhs: PaginatorState, rhs: PaginatorState) -> Bool {
  switch (lhs, rhs) {
  case (.Default, .Default): return true
  case (.InMotion(let lhsProgress), .InMotion(let rhsProgress)):
    if lhsProgress == rhsProgress { return true }
    return false
  case (.Loading, .Loading): return true
  default: return false
  }
}
