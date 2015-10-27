//
//  UITableView+RefreshControl.swift
//  Snowball
//
//  Created by James Martinez on 2/27/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

private var refreshControlAssociationKey: UInt8 = 0

extension UITableView {

  var refreshControl: UIRefreshControl? {
    get {
      return objc_getAssociatedObject(self, &refreshControlAssociationKey) as? UIRefreshControl
    }
    set(newValue) {
      objc_setAssociatedObject(self, &refreshControlAssociationKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN)
    }
  }

  // MARK: - Internal

  func addRefreshControl(target: AnyObject, action: Selector) {
    let refreshControl = UIRefreshControl()
    refreshControl.addTarget(target, action: action, forControlEvents: UIControlEvents.ValueChanged)
    insertSubview(refreshControl, atIndex: 0)
    self.refreshControl = refreshControl
  }
}
