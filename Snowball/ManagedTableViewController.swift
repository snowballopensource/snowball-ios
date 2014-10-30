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

  func cellTypeInSection(section: Int) -> UITableViewCell.Type {
    requireSubclass()
    return UITableViewCell.self
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    cell.configureForObject(objectsInSection(indexPath.section).objectAtIndex(UInt(indexPath.row)))
  }

  private func registerCells() {
    for i in 0...tableView.numberOfSections() {
      tableView.registerClass(cellTypeInSection(i), forCellReuseIdentifier: cellTypeInSection(i).identifier)
    }
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.frame = view.bounds
    view.addSubview(tableView)
    tableView.dataSource = self
    tableView.delegate = self
    registerCells()
  }

  // MARK: UITableViewDataSource

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return Int(objectsInSection(section).count)
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier(cellTypeInSection(indexPath.section).identifier, forIndexPath: indexPath) as UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  // MARK: UITableViewDelegate

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return cellTypeInSection(indexPath.section).height()
  }
}