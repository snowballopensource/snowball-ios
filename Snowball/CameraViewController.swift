//
//  CameraViewController.swift
//  Snowball
//
//  Created by James Martinez on 12/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import UIKit

class CameraViewController: UIViewController, CaptureSessionControllerDelegate {
  private lazy var captureSessionController = CaptureSessionController() // This cannot be initialized twice, as UIViewController subclasses sometimes do (see: http://stackoverflow.com/q/26084583/801858 ), so it's lazy

  func flipCamera() {
    captureSessionController.changeCamera()
  }

  // MARK: Actions

  func toggleRecording(sender: UILongPressGestureRecognizer) {
    switch (sender.state) {
      case UIGestureRecognizerState.Began: captureSessionController.beginRecording()
      case UIGestureRecognizerState.Ended: captureSessionController.endRecording()
      default: return
    }
  }

  // MARK: -

  // MARK: UIViewController

  override func loadView() {
    view = CameraView()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    captureSessionController = CaptureSessionController()
    let cameraView = view as CameraView
    cameraView.session = captureSessionController.captureSession
    captureSessionController.delegate = self
    captureSessionController.startSession()
    cameraView.backgroundColor = UIColor.whiteColor()

    let recordingGestureRecognizer = UILongPressGestureRecognizer()
    recordingGestureRecognizer.minimumPressDuration = 0.2
    recordingGestureRecognizer.addTarget(self, action: "recordingGestureRecognizerStateDidChange")
    cameraView.addGestureRecognizer(recordingGestureRecognizer)
  }

  // MARK: CaptureSessionControllerDelegate

  func movieRecordedToFileAtURL(fileURL: NSURL, error: NSError?) {
    if error != nil { error?.display(); return }
    println("movie recorded")
    // TODO: send to main vc, who will send to preview
    // thought: register mainvc as delegate instead?
  }
}