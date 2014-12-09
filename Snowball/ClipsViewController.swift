//
//  ClipsViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class ClipsViewController: UIViewController, UICollectionViewDelegateFlowLayout, AddClipCollectionReuseableViewDelegate {
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
    let cellTypes: [UICollectionViewCell.Type] = [
      ClipCollectionViewCell.self
    ]
    return ClipsDataSource(collectionView: self.collectionView, entityName: Clip.entityName(), sortDescriptors: [NSSortDescriptor(key: "createdAt", ascending: true)], cellTypes: cellTypes)
  }()

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

    API.request(Router.GetClipStream).responseJSON { (request, response, object, error) in
      
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    let lastSection = collectionViewDataSource.numberOfSectionsInCollectionView(collectionView) - 1
    let lastItem = collectionViewDataSource.collectionView(collectionView, numberOfItemsInSection: lastSection) - 1
    let lastIndexPath = NSIndexPath(forItem: lastItem, inSection: lastSection)
    collectionView.scrollToItemAtIndexPath(lastIndexPath, atScrollPosition: UICollectionViewScrollPosition.Right, animated: false)
  }

  // MARK: - UICollectionViewDelegateFlowLayout

  func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
    sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
      return collectionViewDataSource.cellTypes[indexPath.section].size()
  }

  // MARK: - AddClipCollectionReuseableViewDelegate

  func addClipButtonTapped() {
    // TODO: POST clip
    println("add clip button")
    let clip = Clip.newEntity() as Clip
    let user = User.newEntity() as User
    user.name = "James"
    clip.user = user
    clip.createdAt = NSDate()
    clip.save()
  }
}

class ClipsDataSource: FetchedResultsCollectionViewDataSource {
  var addClipViewDelegate: AddClipCollectionReuseableViewDelegate?

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String,
    atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
    let addClipView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: NSStringFromClass(AddClipCollectionReuseableView), forIndexPath: indexPath) as AddClipCollectionReuseableView
    addClipView.delegate = addClipViewDelegate
    return addClipView
  }

}
