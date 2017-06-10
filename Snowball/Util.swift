//
//  Util.swift
//  Snowball
//
//  Created by James Martinez on 12/31/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation

func isDebug() -> Bool {
  var debug = false
  if _isDebugAssertConfiguration() {
    debug = true
  }
  return debug
}

func performAfterDelay(_ seconds: Double, closure: @escaping () -> Void) {
  DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(seconds * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) {
    closure()
  }
}
