//
//  ManagedTableViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ManagedTableViewController: ManagedViewController, UITableViewDataSource {
  let tableView = UITableView(frame: CGRectZero, style: UITableViewStyle.Plain)

  func cellType() -> UITableViewCell.Type {
    requireSubclass()
    return UITableViewCell.self
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    requireSubclass()
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.frame = view.bounds
    view.addSubview(tableView)
    tableView.dataSource = self
  }

  // MARK: UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Int(objects().count)
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellType().identifier, forIndexPath: indexPath) as UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }
}