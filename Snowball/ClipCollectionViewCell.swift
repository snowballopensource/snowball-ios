//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class ClipCollectionViewCell: UICollectionViewCell {

  // MARK: Properties

  class var defaultSize: CGSize {
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    let cellsPerScreen: CGFloat = 2.5
    let cellWidth = screenWidth / cellsPerScreen
    return CGSizeMake(cellWidth, cellHeight)
  }

  var delegate: ClipCollectionViewCellDelegate?

  let thumbnailImageView = UIImageView()
  let playButton = UIButton()

  // MARK: Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(thumbnailImageView)
    constrain(thumbnailImageView) { thumbnailImageView in
      thumbnailImageView.left == thumbnailImageView.superview!.left
      thumbnailImageView.top == thumbnailImageView.superview!.top
      thumbnailImageView.right == thumbnailImageView.superview!.right
      thumbnailImageView.height == thumbnailImageView.width
    }

    addSubview(playButton)
    constrain(playButton, thumbnailImageView) { (playButton, thumbnailImageView) in
      playButton.left == thumbnailImageView.left
      playButton.top == thumbnailImageView.top
      playButton.right == thumbnailImageView.right
      playButton.height == thumbnailImageView.height
    }
    playButton.addTarget(self, action: "playButtonTapped", forControlEvents: .TouchUpInside)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UICollectionViewCell

  override func prepareForReuse() {
    thumbnailImageView.image = nil
  }

  // MARK: Internal

  func configueForClip(clip: Clip) {
    if let thumbnailURLString = clip.thumbnailURL, thumbnailURL = NSURL(string: thumbnailURLString) {
      thumbnailImageView.setImageFromURL(thumbnailURL)
    }
  }

  // MARK: Private

  @objc private func playButtonTapped() {
    delegate?.clipCollectionViewCellPlayButtonTapped(self)
  }
}

// MARK: - ClipCollectionViewCellDelegate
protocol ClipCollectionViewCellDelegate {
  func clipCollectionViewCellPlayButtonTapped(cell: ClipCollectionViewCell)
}
