//
//  Util.swift
//  Snowball
//
//  Created by James Martinez on 12/31/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation

func performAfterDelay(seconds: Double, closure: () -> Void) {
  dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(seconds * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) {
    closure()
  }
}