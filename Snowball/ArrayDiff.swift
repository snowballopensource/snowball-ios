//
//  ArrayDiff.swift
//  Snowball
//
//  Created by James Martinez on 8/9/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation

struct ArrayDiff {
  static func mergeArrayByPrepending<T: Hashable>(new: [T], toArray old: [T]) -> (additions: [T], duplicates: [T], final: [T]) {
    var duplicates = [T]()
    let additions = new.filter { element in
      if old.contains(element) {
        duplicates.append(element)
        return false
      } else {
        return true
      }
    }
    let final = additions + old
    return (additions, duplicates, final)
  }
}