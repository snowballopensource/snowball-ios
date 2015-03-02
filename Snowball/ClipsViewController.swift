//
//  ClipsViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/2/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

class ClipsViewController: UIViewController {

  // MARK: - Properties

  private let playerView: PlayerView = {
    let view = PlayerView()
    view.backgroundColor = UIColor.blackColor()
    return view
    }()

  private let player = AVPlayer()

  private let collectionView: UICollectionView = {
    let flowLayout = UICollectionViewFlowLayout()
    flowLayout.scrollDirection = UICollectionViewScrollDirection.Horizontal
    flowLayout.minimumInteritemSpacing = 0
    flowLayout.minimumLineSpacing = 0
    flowLayout.itemSize = ClipCollectionViewCell.size

    let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: flowLayout)
    collectionView.backgroundColor = UIColor.whiteColor()
    collectionView.registerClass(ClipCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ClipCollectionViewCell))
    collectionView.showsHorizontalScrollIndicator = false
    return collectionView
    }()

  private let activityIndicatorView: UIActivityIndicatorView = {
    let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.WhiteLarge)
    activityIndicatorView.color = UIColor.darkGrayColor()
    return activityIndicatorView
    }()

  private var clips: [Clip] = []

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    playerView.player = player
    view.addSubview(playerView)
    layout(playerView) { (playerView) in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.height == playerView.width
    }

    let collectionViewWidthPreloadMultiple: CGFloat = 3
    let rightInset = view.bounds.width * collectionViewWidthPreloadMultiple - view.bounds.width
    collectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightInset)
    collectionView.dataSource = self
    collectionView.delegate = self
    view.addSubview(collectionView)
    layout(collectionView, playerView) { (collectionView, playerView) in
      collectionView.left == collectionView.superview!.left
      collectionView.top == playerView.bottom
      collectionView.width == collectionView.superview!.width * collectionViewWidthPreloadMultiple
      collectionView.bottom == collectionView.superview!.bottom
    }

    collectionView.addSubview(activityIndicatorView)
    layout(activityIndicatorView) { (activityIndicatorView) in
      activityIndicatorView.centerX == activityIndicatorView.superview!.centerX / collectionViewWidthPreloadMultiple
      activityIndicatorView.top == activityIndicatorView.superview!.top + 50
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    NSNotificationCenter.defaultCenter().addObserver(self, selector: "refresh", name: UIApplicationWillEnterForegroundNotification, object: nil)

    refresh()
  }

  override func viewWillDisappear(animated: Bool) {
    super.viewWillDisappear(animated)

    NSNotificationCenter.defaultCenter().removeObserver(self)
  }

  // MARK: - Private

  @objc private func refresh() {
    activityIndicatorView.startAnimating()
    API.request(Router.GetClipStream).responseJSON { (request, response, JSON, error) in
      if let JSON = JSON as? [AnyObject] {
        self.clips = Clip.importJSON(JSON)
        self.collectionView.reloadData()
      }
      self.activityIndicatorView.stopAnimating()
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
    let clip = clips[indexPath.row]
    cell.configureForClip(clip)
    return cell
  }
}

// MARK: -

extension ClipsViewController: UICollectionViewDelegate {

  // MARK: - UICollectionViewDelegate

  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    let clip = clips[indexPath.row]
    if let videoURL = clip.videoURL {
      CachedURLAsset.createAssetFromRemoteURL(videoURL) { (asset, error) in
        error?.print("creating cached asset")
        if let asset = asset {
          let playerItem = ClipPlayerItem(clip: clip, asset: asset)
          self.player.replaceCurrentItemWithPlayerItem(playerItem)
          self.player.play()
        }
      }
    }
  }
}