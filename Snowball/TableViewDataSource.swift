//
//  TableViewDataSource.swift
//  Snowball
//
//  Created by James Martinez on 1/27/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class TableViewDataSource: NSObject, UITableViewDataSource {
  var cellTypes = [UITableViewCell.Type]()

  // MARK: - Initializers

  init(tableView: UITableView, cellTypes: [UITableViewCell.Type]) {
    self.cellTypes = cellTypes
    for cellType in cellTypes {
      tableView.registerCellClass(cellType)
    }
  }

  // MARK: - UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    requireSubclass()
    return 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(cellTypes[indexPath.section]),
      forIndexPath: indexPath) as UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  // MARK: - TableViewDataSource

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    requireSubclass()
  }
}