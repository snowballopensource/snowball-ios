//
//  FormTableView.swift
//  Snowball
//
//  Created by James Martinez on 3/7/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

class FormTableView: UITableView {

  // MARK: - Initializers

  convenience override init() {
    self.init(frame: CGRectZero, style: UITableViewStyle.Plain)
  }

  override init(frame: CGRect, style: UITableViewStyle) {
    super.init(frame: frame, style: style)
    allowsSelection = false
    separatorStyle = UITableViewCellSeparatorStyle.None
    rowHeight = TextFieldTableViewCell.height
    registerClass(TextFieldTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(TextFieldTableViewCell))
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
}
