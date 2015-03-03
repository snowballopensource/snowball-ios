//
//  CameraViewController.swift
//  Snowball
//
//  Created by James Martinez on 3/3/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Cartography
import UIKit

class CameraViewController: UIViewController {

  // MARK: - Properties

  var delegate: CameraViewControllerDelegate?

  private let cameraView: CameraView = {
    let view = CameraView()
    view.backgroundColor = UIColor.blackColor()
    let previewLayer = view.layer as AVCaptureVideoPreviewLayer
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    return view
    }()

  private let captureSession = AVCaptureSession()

  private let captureSessionQueue = dispatch_queue_create("CaptureSessionQueue", DISPATCH_QUEUE_SERIAL)

  private var currentVideoDeviceInput: AVCaptureDeviceInput!

  private var movieFileOutput: AVCaptureMovieFileOutput!

  private let kDefaultCameraPositionKey = "DetaultCameraPosition"
  private var defaultCameraPosition: AVCaptureDevicePosition {
    get {
      let lastCameraPositionString = NSUserDefaults.standardUserDefaults().objectForKey(kDefaultCameraPositionKey) as? String
      if lastCameraPositionString == "back" {
        return AVCaptureDevicePosition.Back
      }
      return AVCaptureDevicePosition.Front
    }
    set {
      var lastCameraPositionString: String!
      if newValue == AVCaptureDevicePosition.Back {
        lastCameraPositionString = "back"
      } else {
        lastCameraPositionString = "front"
      }
      NSUserDefaults.standardUserDefaults().setObject(lastCameraPositionString, forKey: kDefaultCameraPositionKey)
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }

  private let playerView = PlayerView()

  private var player: CameraPreviewPlayer {
    return playerView.player as CameraPreviewPlayer
  }

  private var cancelPreviewButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "x"), forState: UIControlState.Normal)
    return button
    }()

  private let progressView: UIProgressView = {
    let progressView = UIProgressView()
    progressView.progressTintColor = UIColor.SnowballColor.greenColor
    progressView.trackTintColor = UIColor.clearColor()
    return progressView
    }()

  private var progressViewTimer: NSTimer?

  private let maxRecordingSeconds = 10.0

  private let FPS: Int32 = 24

  // MARK: - UIViewController

  override func loadView() {
    view = cameraView
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    cameraView.captureSession = captureSession

    checkDeviceAuthorizationStatus()
    dispatch_async(captureSessionQueue) {
      var error: NSError?
      self.captureSession.sessionPreset = AVCaptureSessionPreset640x480
      let videoDevice = self.captureDeviceForMediaType(AVMediaTypeVideo, position: self.defaultCameraPosition)
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
      movieFileOutput.maxRecordedDuration = CMTimeMakeWithSeconds(self.maxRecordingSeconds, self.FPS)
      self.movieFileOutput = movieFileOutput
      if self.captureSession.canAddOutput(movieFileOutput) {
        self.captureSession.addOutput(movieFileOutput)
        if let connection = movieFileOutput.connectionWithMediaType(AVMediaTypeVideo) {
          if connection.supportsVideoStabilization {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.Cinematic
          }
        }
      }
    }

    playerView.player = CameraPreviewPlayer()
    playerView.hidden = true
    view.addSubview(playerView)
    layout(playerView) { (playerView) in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.bottom == playerView.superview!.bottom
    }

    cancelPreviewButton.addTarget(self, action: "cancelPreview", forControlEvents: UIControlEvents.TouchUpInside)
    playerView.addSubview(cancelPreviewButton)
    layout(cancelPreviewButton) { (cancelPreviewButton) in
      cancelPreviewButton.left == cancelPreviewButton.superview!.left
      cancelPreviewButton.top == cancelPreviewButton.superview!.top
      cancelPreviewButton.right == cancelPreviewButton.superview!.right
      cancelPreviewButton.height == 65
    }

    let recordingGestureRecognizer = UILongPressGestureRecognizer()
    recordingGestureRecognizer.minimumPressDuration = 0.2
    recordingGestureRecognizer.addTarget(self, action: "toggleRecording:")
    cameraView.addGestureRecognizer(recordingGestureRecognizer)

    view.addSubview(progressView)
    layout(progressView) { (progressView) in
      progressView.left == progressView.superview!.left
      progressView.top == progressView.superview!.top
      progressView.right == progressView.superview!.right
      progressView.height == 20
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)

    if captureSession.running {
      endSession()
      beginSession()
    } else {
      beginSession()
    }
  }

  override func viewDidDisappear(animated: Bool) {
    super.viewDidDisappear(animated)

    endSession()
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
      defaultCameraPosition = newPosition
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

  // MARK: - Private

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
    dispatch_async(captureSessionQueue) {
      self.captureSession.startRunning()
    }
  }

  private func endSession() {
    dispatch_async(captureSessionQueue) {
      self.captureSession.stopRunning()
    }
  }

  private func beginRecording() {
    dispatch_async(captureSessionQueue) {
      if let recording = self.movieFileOutput?.recording {
        if !recording {
          let outputFileName = "video".stringByAppendingPathExtension("mov")!
          let outputFilePath = NSTemporaryDirectory().stringByAppendingPathComponent(outputFileName)
          self.movieFileOutput?.startRecordingToOutputFileURL(NSURL(fileURLWithPath: outputFilePath), recordingDelegate: self)
        }
      }
    }
  }

  private func endRecording() {
    dispatch_async(captureSessionQueue) {
      if let recording = self.movieFileOutput?.recording {
        if recording {
          self.movieFileOutput?.stopRecording()
        }
      }
    }
  }

  private func setFocusLocked(locked: Bool) {
    dispatch_async(captureSessionQueue) {
      let captureDevice = self.currentVideoDeviceInput?.device
      if let captureDevice = captureDevice {
        let focusMode = locked ? AVCaptureFocusMode.Locked : AVCaptureFocusMode.ContinuousAutoFocus
        if captureDevice.isFocusModeSupported(focusMode) {
          captureDevice.lockForConfiguration(nil)
          captureDevice.focusMode = focusMode
          captureDevice.unlockForConfiguration()
        }
      }
    }
  }

  private func beginProgressViewAnimation() {
    progressView.progress = 0
    let timeInterval = 1.0/30.0 // 30 FPS
    progressViewTimer = NSTimer.scheduledTimerWithTimeInterval(timeInterval, target: self, selector: "progressViewTimerDidFire:", userInfo: timeInterval, repeats: true)
  }

  private func endProgressViewAnimation() {
    progressViewTimer?.invalidate()
    progressViewTimer = nil
  }

  private func resetProgressViewAnimation() {
    progressView.progress = 0
  }

  @objc private func progressViewTimerDidFire(timer: NSTimer) {
    let timeInterval = timer.userInfo as Double
    if progressView.progress <= 1 {
      progressView.progress += Float(timeInterval / maxRecordingSeconds)
    }
  }

  private func previewVideo(url: NSURL) {
    playerView.hidden = false
    player.playVideo(url)
  }

  private func endPreview() {
    playerView.hidden = true
    player.stop()
  }

  @objc private func cancelPreview() {
    endPreview()
    delegate?.videoPreviewDidCancel()
  }
}

// MARK: -

extension CameraViewController: AVCaptureFileOutputRecordingDelegate {

  // MARK: - AVCaptureFileOutputRecordingDelegate

  func captureOutput(captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAtURL fileURL: NSURL!, fromConnections connections: [AnyObject]!) {
    setFocusLocked(true)
    beginProgressViewAnimation()
    delegate?.videoDidBeginRecording()
  }

  func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
    setFocusLocked(false)
    endProgressViewAnimation()
    // Crop video
    // http://stackoverflow.com/a/5231713/801858
    let asset = AVAsset.assetWithURL(outputFileURL) as AVAsset
    let videoTrack = asset.tracksWithMediaType(AVMediaTypeVideo).first as AVAssetTrack

    // When thinking about the following code, think of capturing video in landscape!
    // e.g. videoTrack.naturalSize.height is the width if you are holding the phone portrait
    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = CGSizeMake(videoTrack.naturalSize.height, videoTrack.naturalSize.height)
    videoComposition.frameDuration = CMTimeMake(1, FPS) // 24 FPS

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)

    let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

    // Crop to middle of the view
    // http://www.one-dreamer.com/cropping-video-square-like-vine-instagram-xcode/
    let initialTransform = CGAffineTransformMakeTranslation(videoTrack.naturalSize.height, -(videoTrack.naturalSize.width - videoTrack.naturalSize.height) / 2 )
    let transform = CGAffineTransformRotate(initialTransform, CGFloat(M_PI_2))

    transformer.setTransform(transform, atTime: kCMTimeZero)
    instruction.layerInstructions = [transformer]
    videoComposition.instructions = [instruction]

    let randomString = NSUUID().UUIDString
    let exportedVideoURL = outputFileURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent("video_\(randomString).mp4")
    let exportedThumbnailURL = exportedVideoURL.URLByDeletingLastPathComponent!.URLByAppendingPathComponent("image_\(randomString).png")

    // Export
    NSFileManager.defaultManager().removeItemAtURL(outputFileURL, error: nil)
    NSFileManager.defaultManager().removeItemAtURL(exportedVideoURL, error: nil)
    NSFileManager.defaultManager().removeItemAtURL(exportedThumbnailURL, error: nil)

    let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
    exporter.videoComposition = videoComposition
    exporter.outputURL = exportedVideoURL
    exporter.outputFileType = AVFileTypeMPEG4
    exporter.exportAsynchronouslyWithCompletionHandler {
      let asset = AVURLAsset(URL: exportedVideoURL, options: nil)
      let imageGenerator = AVAssetImageGenerator(asset: asset)
      let imageRef = imageGenerator.copyCGImageAtTime(kCMTimeZero, actualTime: nil, error: nil)
      let thumbnailData = UIImagePNGRepresentation(UIImage(CGImage: imageRef))
      thumbnailData.writeToURL(exportedThumbnailURL, atomically: true)
      dispatch_async(dispatch_get_main_queue()) {
        self.resetProgressViewAnimation()
        self.previewVideo(exporter.outputURL)
        self.delegate?.videoDidEndRecordingToFileAtURL(exporter.outputURL, thumbnailURL: exportedThumbnailURL)
      }
    }
  }
}

// MARK: -

protocol CameraViewControllerDelegate {
  func videoDidBeginRecording()
  func videoDidEndRecordingToFileAtURL(videoURL: NSURL, thumbnailURL: NSURL)
  func videoPreviewDidCancel()
}
