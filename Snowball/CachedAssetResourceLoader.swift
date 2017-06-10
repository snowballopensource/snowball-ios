//
//  CachedAssetResourceLoader.swift
//  Snowball
//
//  Created by James Martinez on 1/6/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation
import Haneke
import MobileCoreServices

class CachedAssetResourceLoader: NSObject {

  // MARK: Properties

  static let sharedInstance = CachedAssetResourceLoader()
  static let handledScheme = "cachedAssetResourceLoaderScheme"
}

// MARK: - AVAssetResourceLoaderDelegate
extension CachedAssetResourceLoader: AVAssetResourceLoaderDelegate {
  func resourceLoader(_ resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
    if let URL = loadingRequest.request.url {
      if URL.scheme == CachedAssetResourceLoader.handledScheme {

        guard var components = URLComponents(url: URL, resolvingAgainstBaseURL: true) else { return false }
        components.scheme = "http"
        guard let remoteURL = components.url else { return false }

        let cache = Shared.dataCache
        cache.fetch(URL: remoteURL).onSuccess({ data in
          if let contentInformationRequest = loadingRequest.contentInformationRequest {
            let fileExtension = URL.pathExtension
            guard let UTI = self.UTIFromFileExtension(fileExtension) else { return }
            contentInformationRequest.contentType = UTI
            contentInformationRequest.contentLength = Int64(data.count)
            contentInformationRequest.isByteRangeAccessSupported = true
          }

          if let dataRequest = loadingRequest.dataRequest {
            let requestedData = data.subdata(in: Int(dataRequest.requestedOffset)..<dataRequest.requestedLength)
            dataRequest.respond(with: requestedData)
          }

          loadingRequest.finishLoading()
        }).onFailure({ error in
          loadingRequest.finishLoading(with: error)
        })

        return true
      }
    }
    return false
  }

  fileprivate func UTIFromFileExtension(_ fileExtension: String) -> String? {
    guard let UTI: CFString = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as NSString, nil)?.takeRetainedValue() else { return nil }
    return UTI as String
  }
}
