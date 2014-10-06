//
//  ManagedTableViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ManagedTableViewController: ManagedViewController, UITableViewDataSource, UITableViewDelegate {
  let tableView = UITableView()

  func cellType() -> UITableViewCell.Type {
    requireSubclass()
    return UITableViewCell.self
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    cell.configureForObject(objectsInSection(indexPath.section).objectAtIndex(UInt(indexPath.row)))
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    view.addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
  }

  override func viewWillLayoutSubviews() {
    tableView.frame = view.bounds
  }

  // MARK: UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Int(objectsInSection(section).count)
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellType().identifier, forIndexPath: indexPath) as UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }
}