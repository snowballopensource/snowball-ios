//
//  ClipsViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

protocol ClipsViewControllerDelegate {
  func clipSelected(clip: Clip)
  func addClipButtonTapped()
}

class ClipsOldViewController: UIViewController, UICollectionViewDelegateFlowLayout, ClipCollectionViewCellDelegate, AddClipCollectionReuseableViewDelegate {
  var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    let flowLayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.headerReferenceSize = ClipTimelineBufferCollectionReuseableView.size
    collectionView.backgroundColor = UIColor.whiteColor()
    return collectionView
  }()
  lazy var collectionViewDataSource: ClipsDataSource = {
    return ClipsDataSource(collectionView: self.collectionView)
  }()
  var delegate: ClipsViewControllerDelegate?
  let currentCellScrollPosition = UICollectionViewScrollPosition.Right

  // MARK: - UIViewController

  override func loadView() {
    view = collectionView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    collectionView.showsHorizontalScrollIndicator = false
    collectionView.registerHeaderClass(ClipTimelineBufferCollectionReuseableView.self)
    collectionView.registerFooterClass(AddClipCollectionReuseableView.self)
    collectionView.dataSource = collectionViewDataSource
    collectionView.delegate = self
    collectionViewDataSource.addClipViewDelegate = self
    collectionViewDataSource.clipCellDelegate = self

    API.request(Router.GetClipStream).responseJSON { (request, response, JSON, error) in
      if let JSON: AnyObject = JSON {
        CoreRecord.saveWithBlock { (context) in
          Clip.objectsFromJSON(JSON, context: context)
          return
        }
      }
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    scrollToUnplayedClip()
  }

  // MARK: - ClipsViewController

  func scrollToClipWithVideoURL(videoURL: NSURL) {
    if let clip = Clip.clipWithVideoURL(videoURL) {
      scrollToClip(clip)
    }
  }

  func scrollToClip(clip: Clip) {
    if let indexPath = collectionViewDataSource.fetchedResultsController.indexPathForObject(clip) {
      collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: currentCellScrollPosition, animated: true)
    }
  }

  func showAddClipButton() {
    UIView.animateWithDuration(1, animations: {
      let flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
      flowLayout.footerReferenceSize = AddClipCollectionReuseableView.size
    }) { (completed) in
      self.scrollToEnd()
    }
  }

  func hideAddClipButton() {
    let lastSection = collectionView.numberOfSections() - 1
    if lastSection >= 0 {
      let lastItem = collectionView.numberOfItemsInSection(lastSection) - 1
      if lastItem >= 0 {
        let indexPath = NSIndexPath(forItem: lastItem, inSection: lastSection)
        collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: currentCellScrollPosition, animated: true)
      }
    }
    let delay = Int64(NSEC_PER_MSEC * 250) // 0.25 seconds
    let time = dispatch_time(DISPATCH_TIME_NOW, delay)
    dispatch_after(time, dispatch_get_main_queue()) {
      let flowLayout = self.collectionView.collectionViewLayout as UICollectionViewFlowLayout
      flowLayout.footerReferenceSize = CGSizeZero
    }
  }

  private func scrollToEnd() {
    let contentSize = collectionView.collectionViewLayout.collectionViewContentSize()
    let width = collectionView.collectionViewLayout.collectionViewContentSize().width
    if width > 0 {
      let endRect = CGRect(x: width - 1, y: 0, width: 1, height: 1)
      collectionView.scrollRectToVisible(endRect, animated: true)
    }
  }

  private func scrollToUnplayedClip() {
    if let clip = Clip.lastPlayedClip() {
      if let indexPath = collectionViewDataSource.fetchedResultsController.indexPathForObject(clip) {
        let nextIndexPath = NSIndexPath(forItem: indexPath.item + 1, inSection: indexPath.section)
        if nextIndexPath.item < collectionView.numberOfItemsInSection(nextIndexPath.section) {
          collectionView.scrollToItemAtIndexPath(nextIndexPath, atScrollPosition: currentCellScrollPosition, animated: true)
        }
      }
    }
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      return collectionViewDataSource.cellTypes[indexPath.section].size
  }

  // MARK: - ClipCollectionViewCellDelegate

  func playClipButtonTappedInCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    scrollToClip(clip)
    delegate?.clipSelected(clip)
  }

  // MARK: - AddClipCollectionReuseableViewDelegate

  func addClipButtonTapped() {
    delegate?.addClipButtonTapped()
  }

  // MARK: - Private

  func clipForCell(cell: ClipCollectionViewCell) -> Clip {
    let indexPath = collectionView.indexPathForCell(cell)!
    return collectionViewDataSource.fetchedResultsController.objectAtIndexPath(indexPath) as Clip
  }
}

// MARK: -

class ClipsDataSource: FetchedResultsCollectionViewDataSource {
  var clipCellDelegate: ClipCollectionViewCellDelegate?
  var addClipViewDelegate: AddClipCollectionReuseableViewDelegate?
  var shouldShowScaledDownThumbnail = false

  init(collectionView: UICollectionView) {
    let cellTypes = [ClipCollectionViewCell.self] as [UICollectionViewCell.Type]
    super.init(collectionView: collectionView, entityName: Clip.entityName(), sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)], getLastPage: true, cellTypes: cellTypes)
  }

  // MARK: - CollectionViewDataSource

  override func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
    let cell = cell as ClipCollectionViewCell
    cell.delegate = clipCellDelegate
    super.configureCell(cell, atIndexPath: indexPath)
  }

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    if kind == UICollectionElementKindSectionFooter {
      let addClipView = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: NSStringFromClass(AddClipCollectionReuseableView), forIndexPath: indexPath) as AddClipCollectionReuseableView
      addClipView.delegate = addClipViewDelegate
      return addClipView
    } else {
      return collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: NSStringFromClass(ClipTimelineBufferCollectionReuseableView), forIndexPath: indexPath) as ClipTimelineBufferCollectionReuseableView
    }
  }

}
