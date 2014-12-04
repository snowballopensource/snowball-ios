//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 10/29/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

class ClipCollectionViewCell: UICollectionViewCell {
  private let clipDetailsLabel = UILabel()
  private let clipThumbnailImageView = UIImageView()

  func setThumbnailImageFromURL(URL: NSURL) {
    Async.userInitiated {
      AVURLAsset.createAssetFromRemoteURL(URL) { (asset, error) in
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        imageGenerator.generateCGImagesAsynchronouslyForTimes([NSValue(CMTime: kCMTimeZero)]) { (requestedTime, image, actualTime, result, error) in
          if error != nil || result != AVAssetImageGeneratorResult.Succeeded {
            println("error generating thumbnail")
            return
          }
          Async.main {
            self.clipThumbnailImageView.image = UIImage(CGImage: image)
          }
        }
      }
    }
  }

  // MARK: -

  // MARK: UICollectionViewCell

  override init(frame: CGRect) {
    super.init(frame: frame)

    contentView.addSubview(clipDetailsLabel)

    clipThumbnailImageView.backgroundColor = UIColor.darkGrayColor()
    contentView.addSubview(clipThumbnailImageView)
  }

  required init(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  override class func size() -> CGSize {
    // From the bottom of the camera/player to the bottom of the screen
    // Camera/player is screen width x screen width, so...
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    return CGSizeMake((screenWidth/2) - (screenWidth/20), cellHeight)
  }

  override func configureForObject(object: AnyObject) {
    let clip = object as Clip
    var clipDetailsString = ""
    if let user = clip.user {
      clipDetailsString = "\(user.username), \(clip.createdAt.shortTimeSinceString())"
    }
    clipDetailsLabel.text = clipDetailsString

    clipThumbnailImageView.image = nil
    let clipVideoURL = NSURL(string: clip.videoURL)
    setThumbnailImageFromURL(clipVideoURL!)
  }

  // MARK: UIView

  override func layoutSubviews() {
    super.layoutSubviews()

    let margin: Float = 13.0

    layout(clipThumbnailImageView) { (clipThumbnailImageView) in
      let sideLength = Float(ClipCollectionViewCell.size().width)
      clipThumbnailImageView.top == clipThumbnailImageView.superview!.top
      clipThumbnailImageView.left == clipThumbnailImageView.superview!.left
      clipThumbnailImageView.height == sideLength
      clipThumbnailImageView.width == sideLength
    }

    layout(clipDetailsLabel, clipThumbnailImageView) { (clipDetailsLabel, clipThumbnailImageView) in
      clipDetailsLabel.top == clipThumbnailImageView.bottom + margin
      clipDetailsLabel.left == clipThumbnailImageView.left + margin
      clipDetailsLabel.right == clipThumbnailImageView.right - margin
    }
  }
}