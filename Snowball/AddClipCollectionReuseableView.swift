//
//  AddClipCollectionReuseableView.swift
//  Snowball
//
//  Created by James Martinez on 12/5/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class AddClipCollectionReuseableView: UICollectionReusableView {

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    addSubview(UIImageView(image: UIImage(named: "add-clip")))
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UICollectionReuseableView+Required

  override class func size() -> CGSize {
    return ClipCollectionViewCell.size()
  }

}
