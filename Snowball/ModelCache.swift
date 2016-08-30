//
//  ModelCache.swift
//  Snowball
//
//  Created by James Martinez on 8/29/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import RocketData

extension DataModelManager {
  static let sharedInstance = DataModelManager(cacheDelegate: ModelCacheDelegate())
}

extension DataProvider {
  convenience init() {
    self.init(dataModelManager: DataModelManager.sharedInstance)
  }
}

extension CollectionDataProvider {
  convenience init() {
    self.init(dataModelManager: DataModelManager.sharedInstance)
  }
}