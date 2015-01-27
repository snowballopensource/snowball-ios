//
//  UITableView+CellRegistration.swift
//  Snowball
//
//  Created by James Martinez on 1/27/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

extension UITableView {
  func registerCellClass(cellClass: UITableViewCell.Type) {
    registerClass(cellClass, forCellReuseIdentifier: NSStringFromClass(cellClass))
  }

  func registerHeaderFooterClass(headerFooterClass: UITableViewHeaderFooterView.Type) {
    registerClass(headerFooterClass, forHeaderFooterViewReuseIdentifier: NSStringFromClass(headerFooterClass))
  }
}
