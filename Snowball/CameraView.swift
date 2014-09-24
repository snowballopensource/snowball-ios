//
//  CameraView.swift
//  Snowball
//
//  Created by James Martinez on 9/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class CameraView: UIView {

  var session: AVCaptureSession {
    get {
      let captureVideoPreviewLayer = self.layer as AVCaptureVideoPreviewLayer
      return captureVideoPreviewLayer.session
    }
    set {
      let captureVideoPreviewLayer = self.layer as AVCaptureVideoPreviewLayer
      captureVideoPreviewLayer.session = newValue
    }
  }

  // MARK: UIView

  override class func layerClass() -> AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    let captureVideoPreviewLayer = self.layer as AVCaptureVideoPreviewLayer
    captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
  }

  required init(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
  }

  convenience override init() {
    self.init(frame: CGRectZero)
  }

}