//
//  RLMObject+.swift
//  Snowball
//
//  Created by James Martinez on 9/18/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

extension RLMObject {
  class func findByID(id: String) -> AnyObject? {
    return objectsWithPredicate(NSPredicate(format: "id = %@", id)).firstObject()
  }
}