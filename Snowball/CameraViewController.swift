//
//  CameraViewController.swift
//  Snowball
//
//  Created by James Martinez on 1/6/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation
import UIKit

protocol CameraViewControllerDelegate {
  func movieRecordedToFileAtURL(fileURL: NSURL, error: NSError?)
}

class CameraViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
  private let captureSession = AVCaptureSession()
  private let cameraView = CameraView()
  private let sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
  private var currentVideoDeviceInput: AVCaptureDeviceInput?
  private var movieFileOutput: AVCaptureMovieFileOutput?
  var delegate: CameraViewControllerDelegate?

  // MARK: - UIViewController

  override func loadView() {
    let previewLayer = cameraView.layer as AVCaptureVideoPreviewLayer
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    view = cameraView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    cameraView.session = captureSession
    checkDeviceAuthorizationStatus()
    dispatch_async(sessionQueue) {
      var error: NSError?
      self.captureSession.sessionPreset = AVCaptureSessionPreset640x480
      let videoDevice = self.captureDeviceForMediaType(AVMediaTypeVideo, position: AVCaptureDevicePosition.Front)
      let videoDeviceInput = AVCaptureDeviceInput(device: videoDevice, error: nil)
      if self.captureSession.canAddInput(videoDeviceInput) {
        self.captureSession.addInput(videoDeviceInput)
        self.currentVideoDeviceInput = videoDeviceInput
      }
      let audioDevice = self.captureDeviceForMediaType(AVMediaTypeAudio)
      let audioDeviceInput = AVCaptureDeviceInput(device: audioDevice, error: nil)
      if self.captureSession.canAddInput(audioDeviceInput) {
        self.captureSession.addInput(audioDeviceInput)
      }
      let movieFileOutput = AVCaptureMovieFileOutput()
      self.movieFileOutput = movieFileOutput
      if self.captureSession.canAddOutput(movieFileOutput) {
        self.captureSession.addOutput(movieFileOutput)
        if let connection = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo) {
          if connection.supportsVideoStabilization {
            connection.enablesVideoStabilizationWhenAvailable = true
          }
        }
      }
    }
    beginSession()

    let recordingGestureRecognizer = UILongPressGestureRecognizer()
    recordingGestureRecognizer.minimumPressDuration = 0.2
    recordingGestureRecognizer.addTarget(self, action: "toggleRecording:")
    cameraView.addGestureRecognizer(recordingGestureRecognizer)
  }

  // MARK: - PlayerViewController

  func toggleRecording(sender: UILongPressGestureRecognizer) {
    switch (sender.state) {
    case UIGestureRecognizerState.Began: beginRecording()
    case UIGestureRecognizerState.Ended: endRecording()
    default: return
    }
  }

  func changeCamera() {
    if let currentCaptureDevice = currentVideoDeviceInput?.device {
      var newPosition = AVCaptureDevicePosition.Front
      switch currentCaptureDevice.position {
      case AVCaptureDevicePosition.Unspecified:
        newPosition = AVCaptureDevicePosition.Front
        break
      case AVCaptureDevicePosition.Back:
        newPosition = AVCaptureDevicePosition.Front
        break
      case AVCaptureDevicePosition.Front:
        newPosition = AVCaptureDevicePosition.Back
        break
      }
      if let newDevice = captureDeviceForMediaType(AVMediaTypeVideo, position: newPosition) {
        var error: NSError?
        let newDeviceInput = AVCaptureDeviceInput(device: newDevice, error: &error)
        captureSession.beginConfiguration()
        captureSession.removeInput(currentVideoDeviceInput)
        if captureSession.canAddInput(newDeviceInput) {
          captureSession.addInput(newDeviceInput)
          currentVideoDeviceInput = newDeviceInput
        }
        captureSession.commitConfiguration()
      }
    }
  }

  private func beginRecording() {
    dispatch_async(sessionQueue) {
      if let recording = self.movieFileOutput?.recording {
        if !recording {
          let outputFileName = "movie".stringByAppendingPathExtension("mov")!
          let outputFilePath = NSTemporaryDirectory().stringByAppendingPathComponent(outputFileName)
          self.movieFileOutput?.startRecordingToOutputFileURL(NSURL(fileURLWithPath: outputFilePath), recordingDelegate: self)
        }
      }
    }
  }

  private func endRecording() {
    dispatch_async(sessionQueue) {
      if let recording = self.movieFileOutput?.recording {
        if recording {
          self.movieFileOutput?.stopRecording()
        }
      }
    }
  }

  private func checkDeviceAuthorizationStatus() {
    AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: nil)
  }

  private func captureDeviceForMediaType(mediaType: String, position: AVCaptureDevicePosition? = nil) -> AVCaptureDevice? {
    let devices = AVCaptureDevice.devicesWithMediaType(mediaType)
    if let captureDevicePosition = position {
      for device in devices {
        let captureDevice = device as AVCaptureDevice
        if captureDevice.position == position {
          return captureDevice
        }
      }
    } else {
      return AVCaptureDevice.devicesWithMediaType(mediaType).first as? AVCaptureDevice
    }
    return nil
  }

  private func beginSession() {
    dispatch_async(sessionQueue) {
      self.captureSession.startRunning()
    }
  }

  private func endSession() {
    dispatch_async(sessionQueue) {
      self.captureSession.stopRunning()
    }
  }

  // MARK: - AVCaptureFileOutputRecordingDelegate

  func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
    // Crop video
    // http://stackoverflow.com/a/5231713/801858
    let asset = AVAsset.assetWithURL(outputFileURL) as AVAsset
    let videoTrack = asset.tracksWithMediaType(AVMediaTypeVideo).first as AVAssetTrack

    // When thinking about the following code, think of capturing video in landscape!
    // e.g. videoTrack.naturalSize.height is the width if you are holding the phone portrait
    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.height)
    let FPS: Int32 = 24
    videoComposition.frameDuration = CMTimeMake(1, FPS) // 24 FPS

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, CMTimeMakeWithSeconds(10, FPS)) // 10 seconds

    let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

    // Crop to middle of the view
    // http://www.one-dreamer.com/cropping-video-square-like-vine-instagram-xcode/
    let initialTransform = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, -(videoTrack.naturalSize.width - videoTrack.naturalSize.height) / 2 )
    let transform = CGAffineTransformRotate(initialTransform, CGFloat(M_PI_2))

    transformer.setTransform(transform, atTime: kCMTimeZero)
    instruction.layerInstructions = [transformer]
    videoComposition.instructions = [instruction]

    let exportedFileURL = outputFileURL.URLByDeletingPathExtension!.URLByAppendingPathExtension("mp4")

    // Export
    let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
    exporter.videoComposition = videoComposition
    exporter.outputURL = exportedFileURL
    exporter.outputFileType = AVFileTypeMPEG4
    NSFileManager.defaultManager().removeItemAtURL(outputFileURL, error: nil)
    NSFileManager.defaultManager().removeItemAtURL(exportedFileURL, error: nil)
    exporter.exportAsynchronouslyWithCompletionHandler {
      if let delegate = self.delegate {
        dispatch_async(dispatch_get_main_queue()) {
          delegate.movieRecordedToFileAtURL(exporter.outputURL, error: error)
        }
      }
    }
  }
}

class CameraView: UIView {
  var session: AVCaptureSession {
    get {
      let cameraLayer = layer as AVCaptureVideoPreviewLayer
      return cameraLayer.session
    }
    set {
      let cameraLayer = layer as AVCaptureVideoPreviewLayer
      cameraLayer.session = newValue
    }
  }

  // MARK: UIView

  override class func layerClass() -> AnyClass {
    return AVCaptureVideoPreviewLayer.self
  }
}