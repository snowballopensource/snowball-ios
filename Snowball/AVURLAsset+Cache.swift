//
//  AVURLAsset+Cache.swift
//  Snowball
//
//  Created by James Martinez on 10/13/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Alamofire
import AVFoundation
import Foundation

extension AVURLAsset {
  typealias CompletionHandler = (AVURLAsset?, NSError?) -> ()

  class func createAssetFromRemoteURL(URL: NSURL, completionHandler: CompletionHandler? = nil) {
    // Create cache file URL using remote URL as key
    var cacheURL = NSFileManager.defaultManager().URLsForDirectory(.CachesDirectory, inDomains: .UserDomainMask)[0] as? NSURL
    let key = URL.absoluteString!.stringByReplacingOccurrencesOfString("/", withString: "").stringByReplacingOccurrencesOfString(":", withString: "")
    cacheURL = cacheURL!.URLByAppendingPathComponent(key)

    // Return asset immediately if it exists in the cache
    if NSFileManager.defaultManager().fileExistsAtPath(cacheURL!.path!) {
      if let completion = completionHandler {
        completion(AVURLAsset(URL: cacheURL!, options: nil), nil)
        return
      }
    }

    // Asset doesn't exist in cache, fetch it
    Alamofire.download(.GET, URL.absoluteString!) { (temporaryURL, response) in
      // Specify where to save download (to the cache URL created above)
      if let cacheURL = cacheURL {
        return cacheURL
      }
      cacheURL = temporaryURL
      return cacheURL!
    }.response { (_, response, _, error) in
      if let error = error {
        if let completion = completionHandler { completion(nil, error) }
      } else {
        if let completion = completionHandler { completion(AVURLAsset(URL: cacheURL!, options: nil), nil) }
      }
    }
  }
}