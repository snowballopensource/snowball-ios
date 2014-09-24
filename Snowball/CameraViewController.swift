//
//  CameraViewController.swift
//  Snowball
//
//  Created by James Martinez on 9/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController {
  private let captureSessionController = CaptureSessionController()

  // MARK: UIViewController

  override func loadView() {
    view = CameraView()
  }

  override func viewDidLoad() {
    let cameraView = view as CameraView
    cameraView.session = captureSessionController.captureSession
    captureSessionController.startSession()
  }
}
