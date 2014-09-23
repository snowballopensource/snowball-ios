//
//  NSError.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

extension NSError {
  func display() {
    UIAlertController(title: NSLocalizedString("Error"), message: localizedDescription, preferredStyle: UIAlertControllerStyle.Alert)
  }
}