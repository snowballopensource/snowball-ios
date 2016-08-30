//
//  TimelineDataCoordinator.swift
//  Snowball
//
//  Created by James Martinez on 8/29/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation
import RocketData

import PINCache // TODO: REMOVE

class TimelineDataCoordinator {

  // MARK: Properties

  let dataProvider = CollectionDataProvider<Clip>()
  let cacheKey = ModelCacheCollectionKey.Timeline.rawValue

  private var currentPage = 1

  // MARK: Initializers

  init() {
    PINCache.sharedCache().removeAllObjects() // TODO: REMOVE

    dataProvider.delegate = self

    dataProvider.fetchDataFromCache(cacheKey: cacheKey) { (clips, error) in
      if let error = error { debugPrint(error) }
      if let clips = clips {
        print("From cache:")
        print(clips)
      }
    }

    fetchFromServer()
  }

  // MARK: Internal

  func fetchFromServer(previousPage previousPage: Bool = false) {
    if previousPage {
      currentPage += 1
    } else {
      currentPage = 1
    }

    SnowballAPI.request(SnowballAPIRoute.ClipStream(page: currentPage)).responseCollection { (response: Response<[Clip], NSError>) in
      switch response.result {
      case .Success(let clips):
        let (_, _, allClips) = ArrayDiff.mergeArrayByPrepending(clips, toArray: self.dataProvider.data)
        self.dataProvider.setData(allClips, cacheKey: self.cacheKey)
      case .Failure(let error): debugPrint(error)
      }
    }
  }
}

// MARK: - CollectionDataProviderDelegate
extension TimelineDataCoordinator: CollectionDataProviderDelegate {
  func collectionDataProviderHasUpdatedData<T>(dataProvider: CollectionDataProvider<T>, collectionChanges: CollectionChange, context: Any?) {
    print("UPDATE")
  }
}