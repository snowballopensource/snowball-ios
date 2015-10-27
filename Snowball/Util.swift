//
//  Util.swift
//  Snowball
//
//  Created by James Martinez on 12/4/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

let isIphone4S = (UIScreen.mainScreen().bounds.height < 568)

func isStaging() -> Bool {
  if let bundleIdentifier = NSBundle.mainBundle().bundleIdentifier {
    if bundleIdentifier == "is.snowball.snowball-staging" {
      return true
    }
  }
  return false
}

func printCurrentQueue() {
  print(String(UTF8String: dispatch_queue_get_label(DISPATCH_CURRENT_QUEUE_LABEL))!)
}