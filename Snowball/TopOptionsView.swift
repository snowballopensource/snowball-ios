//
//  TopOptionsView.swift
//  Snowball
//
//  Created by James Martinez on 9/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class TopOptionsView: UIView {
  let cameraView = UIView()
  private let addButton = UIButton()
  private let videoPreviewView = UIView()
  private var showPreviewView = false

  func animate() {
    showPreviewView = !showPreviewView
    // TODO: animate
  }

  // MARK: UIView

  override init(frame: CGRect) {
    super.init(frame: frame)
    cameraView.backgroundColor = UIColor.lightGrayColor()
    addSubview(cameraView)
    addButton.backgroundColor = UIColor.darkGrayColor()
    addSubview(addButton)
    videoPreviewView.backgroundColor = UIColor.lightGrayColor()
    addSubview(videoPreviewView)

    addButton.addTarget(self, action: Selector("animate"), forControlEvents: UIControlEvents.TouchUpInside)
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  convenience override init() {
    self.init(frame: CGRectZero)
  }

  override func layoutSubviews() {
    layout(cameraView) { (cameraView) in
      cameraView.top == cameraView.superview!.top
      cameraView.bottom == cameraView.superview!.bottom
      cameraView.left == cameraView.superview!.left
      cameraView.width == cameraView.superview!.width / 2
    }
    layout(addButton, cameraView) { (addButton, cameraView) in
      addButton.top == addButton.superview!.top
      addButton.bottom == addButton.superview!.bottom
      addButton.left == cameraView.right
      addButton.width == addButton.superview!.width / 2
    }
    layout(videoPreviewView, addButton) { (videoPreviewView, addButton) in
      videoPreviewView.top == videoPreviewView.superview!.top
      videoPreviewView.bottom == videoPreviewView.superview!.bottom
      videoPreviewView.left == addButton.right
      videoPreviewView.width == videoPreviewView.superview!.width / 2
    }
  }

}
