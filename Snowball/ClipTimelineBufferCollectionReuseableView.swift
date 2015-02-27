//
//  ClipTimelineBufferCollectionReuseableView.swift
//  Snowball
//
//  Created by James Martinez on 1/5/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class ClipTimelineBufferCollectionReuseableView: UICollectionReusableView {

  // MARK: - Properties

  class var size: CGSize {
    let cellSize = ClipCollectionViewCell.size
    let width = UIScreen.mainScreen().bounds.width - cellSize.width
    let size = CGSize(width: width, height: cellSize.height)
    return size
  }

}