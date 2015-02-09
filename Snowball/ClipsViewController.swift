//
//  ClipsViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/9/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class ClipsViewController: UIViewController {

  // MARK: - Properties

  let playerView: UIView = {
    let playerView = UIView()
    playerView.backgroundColor = UIColor.blackColor()
    return playerView
  }()

  let collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.registerClass(ClipCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ClipCollectionViewCell))
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.itemSize = ClipCollectionViewCell.size
    return collectionView
  }()

  var clips = [NewClip]()

  private let kClipBookmarkDateKey = "ClipBookmarkDate"

  var clipBookmarkDate: NSDate? {
    get {
      return NSUserDefaults.standardUserDefaults().objectForKey(kClipBookmarkDateKey) as? NSDate
    }
    set {
      NSUserDefaults.standardUserDefaults().setObject(newValue, forKey: kClipBookmarkDateKey)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    view.addSubview(playerView)
    layout(playerView) { (playerView) in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.height == playerView.superview!.width
    }

    collectionView.dataSource = self
    view.addSubview(collectionView)
    layout(collectionView, playerView) { (collectionView, playerView) in
      collectionView.left == collectionView.superview!.left
      collectionView.top == playerView.bottom
      collectionView.right == collectionView.superview!.right
      collectionView.bottom == collectionView.superview!.bottom
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    refresh()
  }

  // MARK: - Private

  private func refresh() {
    API.request(Router.GetClipStream).responseJSON { (request, response, JSON, error) in
      if let JSON = JSON as? [AnyObject] {
        self.clips = NewClip.importJSON(JSON)
        self.collectionView.reloadData()
        self.scrollToBookmark()
      }
    }
  }

  private func scrollToBookmark() {
    if let bookmarkDate = clipBookmarkDate {
      var previousClip: NewClip?
      for clip in clips {
        if let clipCreatedAt = clip.createdAt {
          if bookmarkDate.compare(clipCreatedAt) == NSComparisonResult.OrderedDescending {
            previousClip = clip
          } else {
            if let previousClip = previousClip {
              let objcClips = clips as NSArray
              let index = objcClips.indexOfObject(previousClip)
              let indexPath = NSIndexPath(forItem: index, inSection: 0)
              collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: UICollectionViewScrollPosition.Left, animated: false)
            }
          }
        }
      }
    }
  }
}

// MARK: -

extension ClipsViewController: UICollectionViewDataSource {

  // MARK: - UICollectionViewDataSource

  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return clips.count
  }

  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ClipCollectionViewCell), forIndexPath: indexPath) as ClipCollectionViewCell
    cell.delegate = self
    cell.configureForClip(clips[indexPath.row])
    return cell
  }
}

// MARK: - 

extension ClipsViewController: ClipCollectionViewCellDelegate {

  // MARK: - ClipCollectionViewCellDelegate

  func playClipButtonTappedInCell(cell: ClipCollectionViewCell) {
    println("play clip")
  }
}
