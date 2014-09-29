//
//  ManagedViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ManagedViewController: UIViewController {

  func objectsInSection(section: Int) -> RLMArray {
    requireSubclass()
    return RLMArray(objectClassName: RLMObject.className())
  }

  func reloadData() {
    requireSubclass()
  }

  // MARK: -

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()
    reloadData()
  }
}