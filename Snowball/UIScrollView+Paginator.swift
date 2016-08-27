//
//  UIScrollView+Paginator.swift
//  Snowball
//
//  Created by James Martinez on 8/26/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

extension UIScrollView {

  // MARK: Associated Keys

  private struct AssociatedKey {
    static var leftPaginator = "leftPaginator"
    static var topPaginator = "topPaginator"
    static var rightPaginator = "rightPaginator"
    static var bottomPaginator = "bottomPaginator"
  }

  // MARK: Properties

  private(set) var leftPaginator: Paginator? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKey.leftPaginator) as? Paginator
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKey.leftPaginator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private(set) var topPaginator: Paginator? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKey.topPaginator) as? Paginator
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKey.topPaginator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private(set) var rightPaginator: Paginator? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKey.rightPaginator) as? Paginator
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKey.rightPaginator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  private(set) var bottomPaginator: Paginator? {
    get {
      return objc_getAssociatedObject(self, &AssociatedKey.bottomPaginator) as? Paginator
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKey.bottomPaginator, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
  }

  // MARK: Internal

  func addPaginator(paginator: Paginator) {
    paginator._scrollView = self

    addSubview(paginator.view)

    switch paginator.position {
    case .Left: leftPaginator = paginator
    case .Top: topPaginator = paginator
    case .Right: rightPaginator = paginator
    case .Bottom: bottomPaginator = paginator
    }
  }
}
