//
//  Array+Merge.swift
//  Snowball
//
//  Created by James Martinez on 9/1/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation

extension Array where Element: Hashable {
  func mergedArrayByPrepending(array: Array) -> Array {
    return uniqueAdditionsFromArray(array) + self
  }

  private func uniqueAdditionsFromArray(array: Array) -> Array {
    return array.filter { element in
      if self.contains(element) { return false }
      return true
    }
  }
}