//
//  NSDate+ISO8601.swift
//  Snowball
//
//  Created by James Martinez on 8/27/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation

extension NSDate {

  private static var iso8610DateFormatter: NSDateFormatter {
    let dateFormatter = NSDateFormatter()
    dateFormatter.locale = NSLocale(localeIdentifier: "en_US_POSIX")
    dateFormatter.timeZone = NSTimeZone.localTimeZone()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZZZZZ"
    return dateFormatter
  }

  var iso8610String: String {
    return NSDate.iso8610DateFormatter.stringFromDate(self)
  }

  static func dateFromISO8610String(ISO8610String: String) -> NSDate? {
    return iso8610DateFormatter.dateFromString(ISO8610String)
  }
}