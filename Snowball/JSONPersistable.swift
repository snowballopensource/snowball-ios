//
//  JSONPersistable.swift
//  Snowball
//
//  Created by James Martinez on 12/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

protocol JSONPersistable: class {
  class func objectFromJSON(JSON: AnyObject) -> Self?
}