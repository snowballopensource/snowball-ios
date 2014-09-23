//
//  ReelsViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ReelsViewController: ManagedTableViewController {

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.registerClass(ReelTableViewCell.self, forCellReuseIdentifier: ReelTableViewCell.identifier)
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
    reelCell.textLabel?.text = "OMG"
  }
}