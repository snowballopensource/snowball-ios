//
//  CacheableModel.swift
//  Snowball
//
//  Created by James Martinez on 8/29/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import RocketData
import Foundation

protocol CacheableModel: Model {
  init?(data: [NSObject: AnyObject])
  func data() -> [NSObject: AnyObject]
}