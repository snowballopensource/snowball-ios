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
}

class ClipsViewController: UIViewController, UICollectionViewDelegateFlowLayout, ClipCollectionViewCellDelegate, AddClipCollectionReuseableViewDelegate {
  var collectionView: UICollectionView = {
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: UICollectionViewFlowLayout())
    let flowLayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.footerReferenceSize = AddClipCollectionReuseableView.size()
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
    collectionView.registerCellClass(ClipCollectionViewCell.self)
    collectionView.registerFooterClass(AddClipCollectionReuseableView.self)
    collectionView.dataSource = collectionViewDataSource
    collectionView.delegate = self
    collectionViewDataSource.addClipViewDelegate = self
    collectionViewDataSource.clipCellDelegate = self

    API.request(Router.GetClipStream).responseJSON { (request, response, JSON, error) in
      if let JSON: AnyObject = JSON {
        CoreRecord.saveWithBlock { (context) in
          Clip.importFromJSON(JSON, context: context)
          return
        }
      }
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if let clip = Clip.firstUnplayedClip() {
      scrollToClip(clip)
    }
  }

  // MARK: - ClipsViewController

  func scrollToClipWithVideoURL(videoURL: NSURL) {
    scrollToClip(Clip.clipWithVideoURL(videoURL))
  }

  private func scrollToClip(clip: Clip) {
    if let indexPath = collectionViewDataSource.fetchedResultsController.indexPathForObject(clip) {
      collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: currentCellScrollPosition, animated: true)
    }
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      return collectionViewDataSource.cellTypes[indexPath.section].size()
  }

  // MARK: - ClipCollectionViewCellDelegate

  func playClipButtonTappedInCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    scrollToClip(clip)
    delegate?.clipSelected(clip)
  }

  func addClipButtonTappedInCell(cell: ClipCollectionViewCell) {
    let clip = clipForCell(cell)
    // TODO: send clip to server
    println("send clip to server")
  }

  // MARK: - AddClipCollectionReuseableViewDelegate

  func addClipButtonTapped() {
    // TODO: move this to when capture vc is done capturing, then when addClipButtonTappedInCell post clip to server
    println("add clip button (OLD)")
    let clip = Clip.newEntity() as Clip
    let user = User.newEntity() as User
    user.name = "James"
    clip.user = user
    clip.createdAt = NSDate()
    clip.save()
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
    super.init(collectionView: collectionView, entityName: Clip.entityName(), sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)], ascending: true, cellTypes: cellTypes)
  }

  // MARK: - CollectionViewDataSource

  override func configureCell(cell: UICollectionViewCell, atIndexPath indexPath: NSIndexPath) {
    let cell = cell as ClipCollectionViewCell
    cell.delegate = clipCellDelegate
    cell.scaleClipThumbnail(shouldShowScaledDownThumbnail, animated: false)
    super.configureCell(cell, atIndexPath: indexPath)
  }

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let addClipView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: NSStringFromClass(AddClipCollectionReuseableView), forIndexPath: indexPath) as AddClipCollectionReuseableView
    addClipView.delegate = addClipViewDelegate
    return addClipView
  }

}
