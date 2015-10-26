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

  private static let baseURL: NSURL = {
    let cachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true)[0]
    return NSURL.fileURLWithPath(cachePath).URLByAppendingPathComponent("DataCache")
    }()

  // MARK: - Initializers

  init() {
    Cache.createDirectory()
  }

  // MARK: - Internal

  func fetchDataAtRemoteURL(remoteURL: NSURL) -> (NSData?, NSURL?) {
    if let data = localDataAtRemoteURL(remoteURL) {
      return (data, localURLForRemoteURL(remoteURL))
    }
    if let data = NSData(contentsOfURL: remoteURL) {
      setDataForKey(data: data, key: keyForRemoteURL(remoteURL))
      return (data, localURLForRemoteURL(remoteURL))
    }
    return (nil, nil)
  }

  func setDataForRemoteURL(data data: NSData, remoteURL: NSURL) -> NSURL? {
    setDataForKey(data: data, key: keyForRemoteURL(remoteURL))
    return localURLForRemoteURL(remoteURL)
  }

  static func removeAllData() {
    do { try NSFileManager.defaultManager().removeItemAtURL(baseURL) } catch {}
    createDirectory()
  }

  // MARK: - Private

  private static func createDirectory() {
    do { try NSFileManager.defaultManager().createDirectoryAtURL(baseURL, withIntermediateDirectories: true, attributes: nil) } catch {}
  }

  private func localDataAtRemoteURL(remoteURL: NSURL) -> NSData? {
    let localURL = localURLForRemoteURL(remoteURL)
    if let data = NSData(contentsOfURL: localURL) {
      return data
    }
    return nil
  }

  private func setDataForKey(data data: NSData, key: String) -> Bool {
    let url = localURLForKey(key)
    return data.writeToURL(url, atomically: true)
  }

  private func localURLForRemoteURL(remoteURL: NSURL) -> NSURL {
    return localURLForKey(keyForRemoteURL(remoteURL))
  }

  private func keyForRemoteURL(url: NSURL) -> String {
    return url.absoluteString
  }

  private func localURLForKey(key: String) -> NSURL {
    let filename = escapedFilenameForKey(key)
    return Cache.baseURL.URLByAppendingPathComponent(filename)
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