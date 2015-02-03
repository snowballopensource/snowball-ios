//
//  FetchedResultsControllerDelegate.swift
//  Snowball
//
//  Created by James Martinez on 2/3/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import CoreData
import UIKit

class FetchedResultsControllerDelegate: NSObject, NSFetchedResultsControllerDelegate {

  // MARK: - Properties

  private var tableView: UITableView?
  private var collectionView: UICollectionView?
  private var collectionViewObjectChanges = [[NSFetchedResultsChangeType: AnyObject]]()
  private var collectionViewSectionChanges = [[NSFetchedResultsChangeType: Int]]()

  // MARK: - Initializers

  init(tableView: UITableView) {
    self.tableView = tableView
  }

  init(collectionView: UICollectionView) {
    self.collectionView = collectionView
  }

  // MARK: - NSFetchedResultsControllerDelegate

  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    if let tableView = tableView {
      switch type {
      case .Insert:
        tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
      case .Delete:
        tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
      default:
        return
      }
    } else if let collectionView = collectionView {
      var change = [NSFetchedResultsChangeType: Int]()
      switch type {
      case NSFetchedResultsChangeType.Insert:
        change[type] = sectionIndex
      case NSFetchedResultsChangeType.Delete:
        change[type] = sectionIndex
      default:
        return
      }
      collectionViewSectionChanges.append(change)
    }
  }

  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    if let tableView = tableView {
      switch type {
      case .Insert:
        tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
      case .Delete:
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      case .Update:
        tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      case .Move:
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
      default:
        return
      }
    } else if let collectionView = collectionView {
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
      collectionViewObjectChanges.append(change)
    }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    if let tableView = tableView {
      tableView.endUpdates()
    } else if let collectionView = collectionView {
      if collectionViewSectionChanges.count > 0 {
        collectionView.performBatchUpdates({
          for change in self.collectionViewSectionChanges {
            for (changeKey, changeValue) in change {
              switch changeKey {
              case NSFetchedResultsChangeType.Insert:
                collectionView.insertSections(NSIndexSet(index: changeValue))
              case NSFetchedResultsChangeType.Delete:
                collectionView.deleteSections(NSIndexSet(index: changeValue))
              case NSFetchedResultsChangeType.Update:
                collectionView.reloadSections(NSIndexSet(index: changeValue))
              default:
                return
              }
            }
          }
          }, completion:nil)
      }
      if collectionViewObjectChanges.count > 0 && collectionViewSectionChanges.count == 0 {
        if collectionView.window == nil {
          collectionView.reloadData()
        } else {
          collectionView.performBatchUpdates({
            for change in self.collectionViewObjectChanges {
              for (changeKey, changeValue) in change {
                switch changeKey {
                case NSFetchedResultsChangeType.Insert:
                  collectionView.insertItemsAtIndexPaths([changeValue])
                case NSFetchedResultsChangeType.Delete:
                  collectionView.deleteItemsAtIndexPaths([changeValue])
                case NSFetchedResultsChangeType.Update:
                  collectionView.reloadItemsAtIndexPaths([changeValue])
                case NSFetchedResultsChangeType.Move:
                  collectionView.moveItemAtIndexPath(changeValue[0] as NSIndexPath, toIndexPath: changeValue[1] as NSIndexPath)
                }
              }
            }
            }, completion: nil)
        }
      }
      collectionViewSectionChanges.removeAll(keepCapacity: false)
      collectionViewObjectChanges.removeAll(keepCapacity: false)
    }
  }
}