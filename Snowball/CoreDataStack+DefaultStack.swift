//
//  CoreDataStack+DefaultStack.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

extension CoreDataStack {
  class var defaultStack: CoreDataStack {
    struct Singleton {
      static let defaultStack: CoreDataStack = CoreDataStack()
    }
    return Singleton.defaultStack
  }
}