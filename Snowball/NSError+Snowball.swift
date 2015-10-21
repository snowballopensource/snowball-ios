//
//  NSError+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 10/21/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation

extension NSError {
  static func snowballErrorWithReason(reason: String) -> NSError {
    return NSError(domain: "is.snowball.snowball.error", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey: reason])
  }
}