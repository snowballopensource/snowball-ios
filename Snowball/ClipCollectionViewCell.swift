//
//  ClipCollectionViewCell.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import UIKit

class ClipCollectionViewCell: UICollectionViewCell {

  // MARK: Properties

  class var defaultSize: CGSize {
    let screenHeight = UIScreen.mainScreen().bounds.height
    let screenWidth = UIScreen.mainScreen().bounds.width
    let cellHeight = screenHeight - screenWidth
    let cellsPerScreen: CGFloat = 3
    let cellWidth = screenWidth / cellsPerScreen
    return CGSizeMake(cellWidth, cellHeight)
  }

}
