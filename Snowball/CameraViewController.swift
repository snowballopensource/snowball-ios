//
//  CameraViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

class CameraViewController: UIViewController {
  private let captureSessionController = CaptureSessionController()

  override func viewDidLoad() {
    let captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSessionController.captureSession)
    view.layer.addSublayer(captureVideoPreviewLayer)
    captureVideoPreviewLayer.frame = view.bounds
    captureSessionController.startSession()
  }
}
