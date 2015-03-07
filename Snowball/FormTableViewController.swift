//
//  FormTableViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/7/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class FormTableViewController: UITableViewController {

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.allowsSelection = false
    tableView.separatorStyle = UITableViewCellSeparatorStyle.None
    tableView.rowHeight = TextFieldTableViewCell.height
    tableView.registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextFieldTableViewCell))
  }

}
