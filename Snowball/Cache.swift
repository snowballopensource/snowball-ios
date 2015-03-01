//
//  Cache.swift
//  Snowball
//
//  Created by James Martinez on 2/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Foundation

struct Cache {

  // MARK: - Properties

  static let sharedCache = Cache()

  private let basePath: String = {
    let cachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0] as String
    let basePath = cachePath.stringByAppendingPathComponent("DataCache")
    var error: NSError?
    NSFileManager.defaultManager().createDirectoryAtPath(basePath, withIntermediateDirectories: true, attributes: nil, error: &error)
    error?.print("creating cache directory")
    return basePath
  }()

  // MARK: - Internal

  func fetchDataAtURL(url: NSURL) -> NSData? {
    if let data = dataAtURL(url) {
      return data
    }
    if let data = NSData(contentsOfURL: url) {
      setDataForKey(data: data, key: keyForURL(url))
      return data
    }
    return nil
  }

//  func removeAllData() {
//    var error: NSError?
//    NSFileManager.defaultManager().removeItemAtPath(basePath, error: &error)
//    error?.print("clearing cache")
//  }

  // MARK: - Private

  private func dataAtURL(url: NSURL) -> NSData? {
    let path = pathForKey(keyForURL(url))
    var error: NSError?
    if let data = NSData(contentsOfFile: path, options: NSDataReadingOptions.allZeros, error: &error) {
      return data
    }
    // error?.print("fetching from cache")
    return nil
  }

  private func setDataForKey(#data: NSData, key: String) -> Bool {
    let path = pathForKey(key)
    var error: NSError?
    let result = data.writeToFile(path, options: NSDataWritingOptions.DataWritingAtomic, error: &error)
    error?.print("writing to cache")
    return result
  }

  private func keyForURL(url: NSURL) -> String {
    return url.absoluteString!
  }

  private func pathForKey(key: String) -> String {
    let filename = escapedFilenameForKey(key)
    let path = basePath.stringByAppendingPathComponent(filename)
    return path
  }

  private func escapedFilenameForKey(key: String) -> String {
    let originalString = key as NSString as CFString
    let charactersToLeaveUnescaped = " \\" as NSString as CFString
    let legalURLCharactersToBeEscaped = "/:" as NSString as CFString
    let encoding = CFStringBuiltInEncodings.UTF8.rawValue
    let escapedPath = CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, originalString, charactersToLeaveUnescaped, legalURLCharactersToBeEscaped, encoding)
    return escapedPath as NSString as String
  }
}