//
//  Util.swift
//  Snowball
//
//  Created by James Martinez on 12/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

let appName = NSBundle.mainBundle().infoDictionary!["CFBundleName"] as String

func NSLocalizedString(key: String) -> String {
  return NSLocalizedString(key, comment: "")
}

func requireSubclass() {
  fatalError("This method should be overridden by a subclass.")
}