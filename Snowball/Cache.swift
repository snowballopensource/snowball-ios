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

  private static let basePath: String = {
    let cachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
    return NSURL.fileURLWithPath(cachePath).URLByAppendingPathComponent("DataCache").absoluteString
    }()

  // MARK: - Initializers

  init() {
    Cache.createDirectory()
  }

  // MARK: - Internal

  func fetchDataAtURL(url: NSURL) -> (NSData?, NSURL?) {
    let (data, cacheURL) = localDataAtURL(url)
    if let data = data {
      return (data, cacheURL)
    }
    if let data = NSData(contentsOfURL: url) {
      setDataForKey(data: data, key: keyForURL(url))
      return (data, NSURL(fileURLWithPath: pathForKey(keyForURL(url))))
    }
    return (nil, nil)
  }

  static func removeAllData() {
    do { try NSFileManager.defaultManager().removeItemAtPath(basePath) } catch {}
    createDirectory()
  }

  // MARK: - Private

  private static func createDirectory() {
    do { try NSFileManager.defaultManager().createDirectoryAtPath(basePath, withIntermediateDirectories: true, attributes: nil) } catch {}
  }

  private func localDataAtURL(url: NSURL) -> (NSData?, NSURL?) {
    let path = pathForKey(keyForURL(url))
    if let data = NSData(contentsOfFile: path) {
      return (data, NSURL(fileURLWithPath: path))
    }
    return (nil, nil)
  }

  private func setDataForKey(data data: NSData, key: String) -> Bool {
    let path = pathForKey(key)
    return data.writeToFile(path, atomically: true)
  }

  private func keyForURL(url: NSURL) -> String {
    return url.absoluteString
  }

  private func pathForKey(key: String) -> String {
    let filename = escapedFilenameForKey(key)
    let path = NSURL(fileURLWithPath: Cache.basePath).URLByAppendingPathComponent(filename)
    return path.absoluteString
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