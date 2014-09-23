//
//  Util.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

typealias CompletionHandler = (NSError?) -> ()

func NSLocalizedString(key: String) -> String {
  return NSLocalizedString(key, comment: "")
}

func requireSubclass() {
  fatalError("This method should be overridden by a subclass.")
}