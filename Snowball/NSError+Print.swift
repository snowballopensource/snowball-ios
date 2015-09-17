//
//  NSError+Print.swift
//  Snowball
//
//  Created by James Martinez on 1/29/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

extension NSError {
  func print(name: String) {
    Swift.print("\(name.capitalizedString) Error: \(description)")
  }
}