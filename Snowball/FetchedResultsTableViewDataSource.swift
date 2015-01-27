//
//  FetchedResultsTableViewDataSource.swift
//  Snowball
//
//  Created by James Martinez on 1/27/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import CoreData
import UIKit

class FetchedResultsTableViewDataSource: TableViewDataSource, NSFetchedResultsControllerDelegate {
  var tableView: UITableView
  var fetchedResultsController: NSFetchedResultsController

  // MARK: - Initializers

  // A duplicate of this next function is maintained in the collection view counterpart to this class.
  init(tableView: UITableView, entityName: String, sectionNameKeyPath: String? = nil, sortDescriptors: [NSSortDescriptor]? = nil, predicate: NSPredicate? = nil, fetchLimit: Int = 25, cellTypes: [UITableViewCell.Type]) {
    self.tableView = tableView
    let fetchRequest = NSFetchRequest()
    let entity = NSEntityDescription.entityForName(entityName, inManagedObjectContext: NSManagedObjectContext.mainQueueContext())
    fetchRequest.entity = entity
    fetchRequest.predicate = predicate
    fetchRequest.fetchBatchSize = 25
    fetchRequest.fetchLimit = fetchLimit
    fetchRequest.sortDescriptors = sortDescriptors ?? [NSSortDescriptor]()
    fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: NSManagedObjectContext.mainQueueContext(), sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
    super.init(tableView: tableView, cellTypes: cellTypes)
    fetchedResultsController.delegate = self
    var error: NSError?
    if !fetchedResultsController.performFetch(&error) {
      abort()
    }
  }

  // MARK: - TableViewDataSource

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let sectionInfo = fetchedResultsController.sections![section] as NSFetchedResultsSectionInfo
    return sectionInfo.numberOfObjects
  }

  override func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let object = fetchedResultsController.objectAtIndexPath(indexPath) as NSManagedObject
    cell.configureForObject(object)
  }

  // MARK: - NSFetchedResultsControllerDelegate

  func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
    switch type {
    case .Insert:
      tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    case .Delete:
      tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
    default:
      return
    }
  }

  func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
    switch type {
    case .Insert:
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    case .Delete:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
    case .Update:
      configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
    case .Move:
      tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
    default:
      return
    }
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableView.endUpdates()
  }
}