//
//  DataCoordinator.swift
//  Snowball
//
//  Created by James Martinez on 8/31/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Alamofire
import Changeset
import Foundation
import RocketData

// DataCoordinator and CollectionDataCoordinator (and their delegate protocols!)
// are largely copies of each other.
// For that reason, I keep them both in this file. Sorry!

// MARK: - DataCoordinator
class DataCoordinator<T: SimpleModel> {

  // MARK: Properties

  var delegate: DataCoordinatorDelegate?

  private let dataProvider = DataProvider<T>()
  private let cacheKey: String

  private(set) var data: T? = nil {
    didSet {
      delegate?.dataCoordinatorDidChangeData(self)
    }
  }

  // MARK: Initializers

  init(cacheKey: String) {
    self.cacheKey = cacheKey

    dataProvider.delegate = self

    dataProvider.fetchDataFromCache(cacheKey: cacheKey) { (data, error) in
      if let error = error { debugPrint(error); return }
      if let data = data { self.data = data }
    }
  }

  // MARK: Internal

  func updateData(data: T) {
    dataProvider.setData(data)
    self.data = data
  }

  func refresh() { assertionFailure("Subclasses of DataCoordinator must implement refresh") }
}

// MARK: - DataProviderDelegate
extension DataCoordinator: DataProviderDelegate {
  func dataProviderHasUpdatedData<T>(dataProvider: DataProvider<T>, context: Any?) {
    data = self.dataProvider.data
  }
}

// MARK: - DataCoordinatorDelegate
protocol DataCoordinatorDelegate {
  func dataCoordinatorDidChangeData<T>(dataCoordinator: DataCoordinator<T>)
}

// MARK: - CollectionDataCoordinator
class CollectionDataCoordinator<T: SimpleModel where T: Equatable> {

  // MARK: Properties

  var delegate: CollectionDataCoordinatorDelegate?

  private let dataProvider = CollectionDataProvider<T>()
  private let cacheKey: String

  private(set) var data = [T]() {
    didSet {
      let changeset = Changeset(source: oldValue, target: data)
      var changes = [CollectionDataCoordinatorChange]()
      for edit in changeset.edits {
        var index = edit.destination
        var newIndex: Int? = nil
        var changeType: CollectionDataCoordinatorChangeType
        switch edit.operation {
        case .Insertion:
          changeType = .Insert
        case .Deletion:
          changeType = .Delete
        case .Move(let origin):
          changeType = .Move
          index = origin
          newIndex = edit.destination
        case .Substitution:
          changeType = .Update
        }
        let change = CollectionDataCoordinatorChange(index: index, destinationIndex: newIndex, type: changeType)
        changes.append(change)
      }
      delegate?.collectionDataCoordinator(self, didChangeData: changes)
    }
  }

  // MARK: Initializers

  init(cacheKey: String) {
    self.cacheKey = cacheKey

    dataProvider.delegate = self

    dataProvider.fetchDataFromCache(cacheKey: cacheKey) { (data, error) in
      if let error = error { debugPrint(error); return }
      if let data = data { self.data = data }
    }
  }

  // MARK: Internal

  func updateData(data: [T]) {
    dataProvider.setData(data, cacheKey: cacheKey)
    self.data = data
  }

  func refresh() { assertionFailure("Subclasses of CollectionDataCoordinator must implement fetchDataFromAPI") }
}

// MARK: - CollectionDataProviderDelegate
extension CollectionDataCoordinator: CollectionDataProviderDelegate {
  func collectionDataProviderHasUpdatedData<T>(dataProvider: CollectionDataProvider<T>, collectionChanges: CollectionChange, context: Any?) {
    data = self.dataProvider.data
  }
}

// MARK: - CollectionDataCoordinatorDelegate
protocol CollectionDataCoordinatorDelegate {
  func collectionDataCoordinator<T>(dataCoordinator: CollectionDataCoordinator<T>, didChangeData changes: [CollectionDataCoordinatorChange])
}

// MARK: - CollectionDataCoordinatorChangeType
enum CollectionDataCoordinatorChangeType {
  case Insert
  case Delete
  case Move
  case Update
}

// MARK: CollectionDataCoordinatorChange
struct CollectionDataCoordinatorChange {
  let index: Int
  let destinationIndex: Int?
  let type: CollectionDataCoordinatorChangeType
}
