//
//  ManagedViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ManagedViewController: UIViewController {

  func objects() -> RLMArray {
    requireSubclass()
    return RLMArray(objectClassName: RLMObject.className())
  }

  func reloadData() {
    requireSubclass()
  }

  // MARK: UIViewController

  override init(nibName: String?, bundle: NSBundle?) {
    super.init(nibName: nibName, bundle: bundle)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override convenience init() {
    self.init(nibName: nil, bundle: nil)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    reloadData()
  }
}