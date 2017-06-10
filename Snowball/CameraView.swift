//
//  CameraView.swift
//  Snowball
//
//  Created by James Martinez on 3/3/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class CameraView: UIView {

  // MARK: Properties

  var captureSession: AVCaptureSession {
    get {
      let captureLayer = layer as! AVCaptureVideoPreviewLayer
      return captureLayer.session
    }
    set {
      let captureLayer = layer as! AVCaptureVideoPreviewLayer
      captureLayer.session = newValue
    }
  }

  // MARK: UIView

  override class var layerClass : AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }
}
