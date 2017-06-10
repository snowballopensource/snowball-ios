//
//  NSDate+ISO8601.swift
//  Snowball
//
//  Created by James Martinez on 7/25/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation

extension Date {
  static func dateFromISO8610String(_ ISO8610String: String) -> Date? {
    let dateFormatter = DateFormatter()
    dateFormatter.locale = Locale(identifier: "en_US_POSIX")
    dateFormatter.timeZone = TimeZone.autoupdatingCurrent
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return dateFormatter.date(from: ISO8610String)
  }
}
