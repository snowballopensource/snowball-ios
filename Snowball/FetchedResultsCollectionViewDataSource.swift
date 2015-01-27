//
//  FetchedResultsCollectionViewDataSource.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData
import UIKit

class FetchedResultsCollectionViewDataSource: CollectionViewDataSource, NSFetchedResultsControllerDelegate {
  var collectionView: UICollectionView
  var fetchedResultsController: NSFetchedResultsController
  var objectChanges = [[NSFetchedResultsChangeType: AnyObject]]()
  var sectionChanges = [[NSFetchedResultsChangeType: Int]]()

  // MARK: - Initializers

  // A duplicate of this next function is maintained in the table view counterpart to this class.
  init(collectionView: UICollectionView, entityName: String, sectionNameKeyPath: String? = nil, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil, fetchLimit: Int = 25, ascending: Bool = false, cellTypes: [UICollectionViewCell.Type]) {
    self.collectionView = collectionView
    let fetchRequest = NSFetchRequest()
    let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: NSManagedObjectContext.mainQueueContext())
    fetchRequest.entity = entity
    fetchRequest.fetchBatchSize = 25
    fetchRequest.fetchLimit = fetchLimit
    fetchRequest.sortDescriptors = sortDescriptors ?? [NSSortDescriptor]()
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.mainQueueContext(), sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
    super.init(collectionView: collectionView, cellTypes: cellTypes)
    fetchedResultsController.delegate = self
    var error: NSError?
    if ascending {
      let count = NSManagedObjectContext.mainQueueContext().countForFetchRequest(fetchRequest, error: &error)
      if error != nil {
        fetchRequest.fetchOffset = (count > 0 ? count : 0)
      }
    }
    if !fetchedResultsController.performFetch(&error) {
      abort()
    }
  }

  // MARK: - CollectionViewDataSource

  override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }

  override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    return sectionInfo.numberOfObjects
  }

  override func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
    let object = self.fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
    cell.configureForObject(object)
  }

  // MARK: - NSFetchedResultsControllerDelegate

  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    var change = [NSFetchedResultsChangeType: Int]()
    switch type {
      case NSFetchedResultsChangeType.Insert:
        change[type] = sectionIndex
      case NSFetchedResultsChangeType.Delete:
        change[type] = sectionIndex
      default:
        return
    }
    sectionChanges.append(change)
  }

  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    var change = [NSFetchedResultsChangeType: AnyObject]()
    switch type {
      case NSFetchedResultsChangeType.Insert:
        change[type] = newIndexPath
      case NSFetchedResultsChangeType.Delete:
        change[type] = indexPath
      case NSFetchedResultsChangeType.Update:
        change[type] = indexPath
      case NSFetchedResultsChangeType.Move:
        change[type] = [indexPath!, newIndexPath!]
    }
    objectChanges.append(change)
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    if sectionChanges.count > 0 {
      collectionView.performBatchUpdates({
        for change in self.sectionChanges {
          for (changeKey, changeValue) in change {
            switch changeKey {
              case NSFetchedResultsChangeType.Insert:
                self.collectionView.insertSections(NSIndexSet(index: changeValue))
              case NSFetchedResultsChangeType.Delete:
                self.collectionView.deleteSections(NSIndexSet(index: changeValue))
              case NSFetchedResultsChangeType.Update:
                self.collectionView.reloadSections(NSIndexSet(index: changeValue))
              default:
                return
            }
          }
        }
      }, completion:nil)
    }
    if objectChanges.count > 0 && sectionChanges.count == 0 {
      if collectionView.window == nil {
        collectionView.reloadData()
      } else {
        collectionView.performBatchUpdates({
          for change in self.objectChanges {
            for (changeKey, changeValue) in change {
              switch changeKey {
                case NSFetchedResultsChangeType.Insert:
                  self.collectionView.insertItemsAtIndexPaths([changeValue])
                case NSFetchedResultsChangeType.Delete:
                  self.collectionView.deleteItemsAtIndexPaths([changeValue])
                case NSFetchedResultsChangeType.Update:
                  self.collectionView.reloadItemsAtIndexPaths([changeValue])
                case NSFetchedResultsChangeType.Move:
                  self.collectionView.moveItemAtIndexPath(changeValue[0] as NSIndexPath, toIndexPath: changeValue[1] as NSIndexPath)
              }
            }
          }
        }, completion: nil)
      }
    }
    sectionChanges.removeAll(keepCapacity: false)
    objectChanges.removeAll(keepCapacity: false)
  }
}
