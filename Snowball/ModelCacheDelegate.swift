//
//  ModelCacheDelegate.swift
//  Snowball
//
//  Created by James Martinez on 8/29/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import PINCache
import RocketData

struct ModelCacheDelegate {
  private let cache = PINCache.sharedCache()
}

// MARK: - CacheDelegate
extension ModelCacheDelegate: CacheDelegate {

  // Data is stored as follows (each is stored [key: value]):
  // Model: [id: data] where data is [NSObject: AnyObject]
  // Collection: [key: [id]] where [id] is [String] (array of individual model IDs)

  func modelForKey<T: SimpleModel>(cacheKey: String?, context: Any?, completion: (T?, NSError?) -> ()) {
    guard
      let cacheKey = cacheKey,
      let data = cache.objectForKey(cacheKey) as? [NSObject: AnyObject],
      let modelType = T.self as? CacheableModel.Type
      else {
        completion(nil, nil) // TODO: Return error as second parameter
        return
    }
    let model = modelType.init(data: data) as? T
    completion(model, nil)
  }

  func setModel<T: SimpleModel>(model: T, forKey cacheKey: String, context: Any?) {
    if let model = model as? CacheableModel {
      cache.setObject(model.data(), forKey: cacheKey)
    } else {
      assertionFailure("SimpleModel is not a CacheableModel")
    }
  }

  func collectionForKey<T: SimpleModel>(cacheKey: String?, context: Any?, completion: ([T]?, NSError?) -> ()) {
    guard
      let cacheKey = cacheKey,
      let modelIDs = cache.objectForKey(cacheKey) as? [String],
      let modelType = T.self as? CacheableModel.Type
      else {
        completion(nil, nil) // TODO: Return error as second parameter
        return
    }

    let collection: [T] = modelIDs.flatMap {
      guard let data = self.cache.objectForKey($0) as? [NSObject: AnyObject] else {
        return nil
      }
      return modelType.init(data: data) as? T
    }
    completion(collection, nil)
  }

  func setCollection<T: SimpleModel>(collection: [T], forKey cacheKey: String, context: Any?) {
    collection.forEach { model in
      if let modelID = model.modelIdentifier {
        setModel(model, forKey: modelID, context: nil)
      }
    }

    let data = collection.flatMap { return $0.modelIdentifier }
    cache.setObject(data, forKey: cacheKey)
  }

  func deleteModel(model: SimpleModel, forKey cacheKey: String?, context: Any?) {
    guard let cacheKey = cacheKey else { return }
    cache.removeObjectForKey(cacheKey)
  }
}