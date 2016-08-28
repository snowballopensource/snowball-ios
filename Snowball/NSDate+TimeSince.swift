//
//  NSDate+TimeSince.swift
//  Snowball
//
//  Created by James Martinez on 8/27/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation

extension NSDate {
  func shortTimeSinceString() -> String {
    let now = NSDate()
    let deltaSeconds = Float(fabs(self.timeIntervalSinceDate(now)))
    let deltaMinutes = deltaSeconds / 60.0
    var value = 0

    if deltaSeconds < 60 {
      value = Int(floor(deltaSeconds))
      return "\(value)s"
    } else if deltaMinutes < 60 {
      value = Int(floor(deltaMinutes))
      return "\(value)m"
    } else if deltaMinutes < (24 * 60) {
      value = Int(floor(deltaMinutes/60))
      return "\(value)h"
    } else if deltaMinutes < (24 * 60 * 7) {
      value = Int(floor(deltaMinutes/(24 * 60)))
      return "\(value)d"
    } else if deltaMinutes < (24 * 60 * 30) {
      value = Int(floor(deltaMinutes/(24 * 60 * 7)))
      return "\(value)w"
    } else if deltaMinutes < (24 * 60 * 365.25) {
      value = Int(floor(deltaMinutes/(24 * 60 * 30)))
      return "\(value)mo"
    } else {
      value = Int(floor(deltaMinutes/(24 * 60 * 365.25)))
      return "\(value)yr"
    }
  }
}