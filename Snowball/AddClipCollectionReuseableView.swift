//
//  AddClipCollectionReuseableView.swift
//  Snowball
//
//  Created by James Martinez on 12/5/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

protocol AddClipCollectionReuseableViewDelegate: class {
  func addClipButtonTapped()
}

class AddClipCollectionReuseableView: UICollectionReusableView {
  var delegate: AddClipCollectionReuseableViewDelegate?

  // MARK: - Initializers

  override init(frame: CGRect) {
    super.init(frame: frame)

    let addClipButton = UIButton(frame: bounds)
    addClipButton.setImage(UIImage(named: "add-clip"), forState: UIControlState.Normal)
    addClipButton.addTarget(delegate, action: "addClipButtonTapped", forControlEvents: UIControlEvents.TouchUpInside)
    addSubview(addClipButton)
  }

  required init(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - UICollectionReuseableView+Required

  override class func size() -> CGSize {
    return ClipCollectionViewCell.size()
  }

}
