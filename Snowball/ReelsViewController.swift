//
//  ReelsViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class ReelsViewController: ManagedTableViewController {
  let topOptionsView = TopOptionsView()

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerClass(ReelTableViewCell.self, forCellReuseIdentifier: ReelTableViewCell.identifier)
    view.addSubview(topOptionsView)
  }

  override func viewWillLayoutSubviews() {
    super.viewWillLayoutSubviews()
    layout(topOptionsView) { (topOptionsView) in
      topOptionsView.top == topOptionsView.superview!.top
      topOptionsView.bottom == topOptionsView.top + Float(ReelTableViewCell.height)
      topOptionsView.left == topOptionsView.superview!.left
      topOptionsView.right == topOptionsView.superview!.right
    }
    layout(tableView, topOptionsView) { (tableView, topOptionsView) in
      tableView.top == topOptionsView.bottom
      tableView.bottom == tableView.superview!.bottom
      tableView.left == tableView.superview!.left
      tableView.right == tableView.superview!.right
    }
  }

  // MARK: ManagedViewController

  override func objects() -> RLMArray {
    return Reel.allObjects()
  }

  override func reloadData() {
    API.getReelStream { (error) -> () in
      if error != nil { error?.display(); return }
      self.tableView.reloadData()
    }
  }

  // MARK: ManagedTableViewController

  override func cellType() -> UITableViewCell.Type {
    return ReelTableViewCell.self
  }

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let reelCell = cell as ReelTableViewCell
    reelCell.configureForObject(objects().objectAtIndex(UInt(indexPath.row)))
  }

  // MARK: UITableViewDataSource

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return ReelTableViewCell.height
  }
}