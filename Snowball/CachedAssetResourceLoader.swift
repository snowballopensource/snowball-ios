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
  func resourceLoader(resourceLoader: AVAssetResourceLoader, shouldWaitForLoadingOfRequestedResource loadingRequest: AVAssetResourceLoadingRequest) -> Bool {
    print("CALLED TO LOAD RESOURCE")

    if let URL = loadingRequest.request.URL {
      if URL.scheme == CachedAssetResourceLoader.handledScheme {

        guard let URLComponents = NSURLComponents(URL: URL, resolvingAgainstBaseURL: true) else { return false }
        URLComponents.scheme = "http"
        guard let remoteURL = URLComponents.URL else { return false }

        let cache = Shared.dataCache
        cache.fetch(URL: remoteURL).onSuccess({ data in
          if let contentInformationRequest = loadingRequest.contentInformationRequest {
            guard let fileExtension = URL.pathExtension else { return }
            guard let UTI = self.UTIFromFileExtension(fileExtension) else { return }
            contentInformationRequest.contentType = UTI
            contentInformationRequest.contentLength = Int64(data.length)
            contentInformationRequest.byteRangeAccessSupported = true
          }

          if let dataRequest = loadingRequest.dataRequest {
            let requesteDataRange = NSRange(location: Int(dataRequest.requestedOffset), length: Int(dataRequest.requestedLength))
            let requestedData = data.subdataWithRange(requesteDataRange)
            dataRequest.respondWithData(requestedData)
          }

          loadingRequest.finishLoading()
        }).onFailure({ error in
          loadingRequest.finishLoadingWithError(error)
        })

        return true
      }
    }
    return false
  }

  private func UTIFromFileExtension(fileExtension: String) -> String? {
    guard let UTI: CFString = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension as NSString, nil)?.takeRetainedValue() else { return nil }
    return UTI as String
  }
}