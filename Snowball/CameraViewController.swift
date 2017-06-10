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

  //
  // TODO: NOTE TO SELF - This class should probably be refactored
  //

  // MARK: Properties

  var delegate: CameraViewControllerDelegate?

  fileprivate let cameraView: CameraView = {
    let view = CameraView()
    view.backgroundColor = UIColor.black
    let previewLayer = view.layer as! AVCaptureVideoPreviewLayer
    previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
    return view
  }()

  fileprivate let captureSession = AVCaptureSession()

  fileprivate let captureSessionQueue = DispatchQueue(label: "CaptureSessionQueue", attributes: [])

  fileprivate var currentVideoDeviceInput: AVCaptureDeviceInput!

  fileprivate var movieFileOutput: AVCaptureMovieFileOutput!

  fileprivate let kDefaultCameraPositionKey = "DetaultCameraPosition"
  fileprivate var defaultCameraPosition: AVCaptureDevicePosition {
    get {
      let lastCameraPositionString = UserDefaults.standard.object(forKey: kDefaultCameraPositionKey) as? String
      if lastCameraPositionString == "back" {
        return AVCaptureDevicePosition.back
      }
      return AVCaptureDevicePosition.front
    }
    set {
      var lastCameraPositionString: String!
      if newValue == AVCaptureDevicePosition.back {
        lastCameraPositionString = "back"
      } else {
        lastCameraPositionString = "front"
      }
      UserDefaults.standard.set(lastCameraPositionString, forKey: kDefaultCameraPositionKey)
      UserDefaults.standard.synchronize()
    }
  }

  fileprivate let playerView = PlayerView()

  fileprivate var player: SingleItemLoopingPlayer {
    return playerView.player as! SingleItemLoopingPlayer
  }

  fileprivate var cancelPreviewButton: UIButton = {
    let button = UIButton()
    button.setImage(UIImage(named: "top-x"), for: UIControlState())
    return button
  }()
  fileprivate let cancelPreviewButtonAnimatableConstraints = ConstraintGroup()

  fileprivate let progressView: UIProgressView = {
    let progressView = UIProgressView()
    progressView.progressTintColor = User.currentUser?.color ?? UIColor.SnowballColor.blueColor
    progressView.trackTintColor = UIColor.clear
    return progressView
  }()

  fileprivate var progressViewTimer: Timer?

  fileprivate let maxRecordingSeconds = 3.0

  fileprivate let FPS: Int32 = 24

  var state: CameraViewControllerState = CameraViewControllerState.default {
    didSet {
      if state == CameraViewControllerState.default {
        setCancelPreviewButtonHidden(true, animated: false)
        playerView.isHidden = true
      } else if state == CameraViewControllerState.previewing {
        playerView.isHidden = false
        setCancelPreviewButtonHidden(false, animated: true)
      }
    }
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    cameraView.captureSession = captureSession

    checkDeviceAuthorizationStatus()
    captureSessionQueue.async {
      self.captureSession.sessionPreset = AVCaptureSessionPreset640x480
      let videoDevice = self.captureDeviceForMediaType(AVMediaTypeVideo, position: self.defaultCameraPosition)
      let videoDeviceInput = try? AVCaptureDeviceInput(device: videoDevice)
      if self.captureSession.canAddInput(videoDeviceInput) {
        self.captureSession.addInput(videoDeviceInput)
        self.currentVideoDeviceInput = videoDeviceInput
      }
      let audioDevice = self.captureDeviceForMediaType(AVMediaTypeAudio)
      let audioDeviceInput = try? AVCaptureDeviceInput(device: audioDevice)
      if self.captureSession.canAddInput(audioDeviceInput) {
        self.captureSession.addInput(audioDeviceInput)
      }
      let movieFileOutput = AVCaptureMovieFileOutput()
      movieFileOutput.maxRecordedDuration = CMTimeMakeWithSeconds(self.maxRecordingSeconds, self.FPS)
      self.movieFileOutput = movieFileOutput
      if self.captureSession.canAddOutput(movieFileOutput) {
        self.captureSession.addOutput(movieFileOutput)
        if let connection = movieFileOutput.connection(withMediaType: AVMediaTypeVideo) {
          if connection.isVideoStabilizationSupported {
            connection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationMode.cinematic
          }
        }
      }
    }

    view.addSubview(cameraView)
    constrain(cameraView) { (cameraView) in
      cameraView.left == cameraView.superview!.left
      cameraView.top == cameraView.superview!.top
      cameraView.right == cameraView.superview!.right
      cameraView.bottom == cameraView.superview!.bottom
    }

    let recordingGestureRecognizer = UILongPressGestureRecognizer()
    recordingGestureRecognizer.minimumPressDuration = 0.2
    recordingGestureRecognizer.addTarget(self, action: #selector(CameraViewController.toggleRecording(_:)))
    cameraView.addGestureRecognizer(recordingGestureRecognizer)

    playerView.player = SingleItemLoopingPlayer()
    playerView.isHidden = true
    view.addSubview(playerView)
    constrain(playerView) { (playerView) in
      playerView.left == playerView.superview!.left
      playerView.top == playerView.superview!.top
      playerView.right == playerView.superview!.right
      playerView.bottom == playerView.superview!.bottom
    }

    cancelPreviewButton.addTarget(self, action: #selector(CameraViewController.cancelPreview), for: UIControlEvents.touchUpInside)
    playerView.addSubview(cancelPreviewButton)
    constrain(cancelPreviewButton) { (cancelPreviewButton) in
      cancelPreviewButton.left == cancelPreviewButton.superview!.left
      cancelPreviewButton.right == cancelPreviewButton.superview!.right
      cancelPreviewButton.height == 65
    }
    setCancelPreviewButtonHidden(true, animated: false)

    view.addSubview(progressView)
    constrain(progressView) { (progressView) in
      progressView.left == progressView.superview!.left
      progressView.top == progressView.superview!.top
      progressView.right == progressView.superview!.right
      progressView.height == 20
    }
  }

  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)

    if captureSession.isRunning {
      endSession()
      beginSession()
    } else {
      beginSession()
    }

    setCancelPreviewButtonHidden(true, animated: false)
  }

  override func viewDidDisappear(_ animated: Bool) {
    super.viewDidDisappear(animated)

    endSession()
  }

  // MARK: Internal

  func changeCamera() {
    if let currentCaptureDevice = currentVideoDeviceInput?.device {
      var newPosition = AVCaptureDevicePosition.front
      switch currentCaptureDevice.position {
      case AVCaptureDevicePosition.unspecified:
        newPosition = AVCaptureDevicePosition.front
        break
      case AVCaptureDevicePosition.back:
        newPosition = AVCaptureDevicePosition.front
        break
      case AVCaptureDevicePosition.front:
        newPosition = AVCaptureDevicePosition.back
        break
      }
      defaultCameraPosition = newPosition
      if let newDevice = captureDeviceForMediaType(AVMediaTypeVideo, position: newPosition) {
        let newDeviceInput = try? AVCaptureDeviceInput(device: newDevice)
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

  func endPreview() {
    state = CameraViewControllerState.default
    player.stop()
  }

  // MARK: Private

  @objc fileprivate func toggleRecording(_ sender: UILongPressGestureRecognizer) {
    switch (sender.state) {
    case .began:
      beginRecording()
    case .ended, .cancelled, .failed:
      endRecording()
    default: return
    }
  }

  fileprivate func checkDeviceAuthorizationStatus() {
    AVCaptureDevice.requestAccess(forMediaType: AVMediaTypeVideo, completionHandler: nil)
  }

  fileprivate func captureDeviceForMediaType(_ mediaType: String, position: AVCaptureDevicePosition? = nil) -> AVCaptureDevice? {
    let devices = AVCaptureDevice.devices(withMediaType: mediaType)
    if let _ = position {
      for device in devices! {
        let captureDevice = device as! AVCaptureDevice
        if captureDevice.position == position {
          return captureDevice
        }
      }
    } else {
      return AVCaptureDevice.devices(withMediaType: mediaType).first as? AVCaptureDevice
    }
    return nil
  }

  fileprivate func beginSession() {
    captureSessionQueue.async {
      self.captureSession.startRunning()
    }
  }

  fileprivate func endSession() {
    captureSessionQueue.async {
      self.captureSession.stopRunning()
    }
  }

  fileprivate func beginRecording() {
    captureSessionQueue.async {
      if let recording = self.movieFileOutput?.isRecording {
        if !recording {
          let documentDirectory = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first!
          let outputFilePath = URL(fileURLWithPath: documentDirectory).appendingPathComponent("video.mov")
          self.movieFileOutput?.startRecording(toOutputFileURL: outputFilePath, recordingDelegate: self)
        }
      }
    }
  }

  fileprivate func endRecording() {
    captureSessionQueue.async {
      if let recording = self.movieFileOutput?.isRecording {
        if recording {
          self.movieFileOutput?.stopRecording()
        }
      }
    }
  }

  fileprivate func setFocusLocked(_ locked: Bool) {
    captureSessionQueue.async {
      let captureDevice = self.currentVideoDeviceInput?.device
      if let captureDevice = captureDevice {
        let focusMode = locked ? AVCaptureFocusMode.locked : AVCaptureFocusMode.continuousAutoFocus
        if captureDevice.isFocusModeSupported(focusMode) {
          do { try captureDevice.lockForConfiguration() } catch {}
          captureDevice.focusMode = focusMode
          captureDevice.unlockForConfiguration()
        }
      }
    }
  }

  fileprivate func beginProgressViewAnimation() {
    progressView.progress = 0
    let timeInterval = 1.0/30.0 // 30 FPS
    progressViewTimer = Timer.scheduledTimer(timeInterval: timeInterval, target: self, selector: #selector(CameraViewController.progressViewTimerDidFire(_:)), userInfo: timeInterval, repeats: true)
  }

  fileprivate func endProgressViewAnimation() {
    progressViewTimer?.invalidate()
    progressViewTimer = nil
  }

  fileprivate func resetProgressViewAnimation() {
    progressView.progress = 0
  }

  @objc fileprivate func progressViewTimerDidFire(_ timer: Timer) {
    let timeInterval = timer.userInfo as! Double
    if progressView.progress < 1 {
      progressView.progress += Float(timeInterval / maxRecordingSeconds)
    }
  }

  fileprivate func previewVideo(_ url: URL) {
    state = CameraViewControllerState.previewing
    player.playVideoURL(url)
  }

  @objc fileprivate func cancelPreview() {
    endPreview()
    delegate?.videoPreviewDidCancel()
  }

  fileprivate func setCancelPreviewButtonHidden(_ hidden: Bool, animated: Bool) {
    if animated {
      UIView.animate(withDuration: 0.4, animations: {
        self.setCancelPreviewButtonHidden(hidden, animated: false)
      }) 
    } else {
      if hidden {
        constrain(cancelPreviewButton, replace: cancelPreviewButtonAnimatableConstraints) { cancelPreviewButton in
          cancelPreviewButton.bottom == cancelPreviewButton.superview!.top
        }
      } else {
        constrain(cancelPreviewButton, replace: cancelPreviewButtonAnimatableConstraints) { cancelPreviewButton in
          cancelPreviewButton.top == cancelPreviewButton.superview!.top + 20
        }
      }
      cancelPreviewButton.layoutIfNeeded()
    }
  }
}

// MARK: - AVCaptureFileOutputRecordingDelegate
extension CameraViewController: AVCaptureFileOutputRecordingDelegate {
  func capture(_ captureOutput: AVCaptureFileOutput!, didStartRecordingToOutputFileAt fileURL: URL!, fromConnections connections: [Any]!) {
    setFocusLocked(true)
    beginProgressViewAnimation()
    state = .recording
    delegate?.videoDidBeginRecording()
  }

  func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
    if let error = error as NSError? {
      let successful = error.userInfo[AVErrorRecordingSuccessfullyFinishedKey] as? NSNumber
      if successful?.boolValue == true {} else {
        // TODO: Show error
        print(error)
      }
    }
    setFocusLocked(false)
    endProgressViewAnimation()
    // Crop video
    // http://stackoverflow.com/a/5231713/801858
    let asset = AVAsset(url: outputFileURL)
    let videoTrack = asset.tracks(withMediaType: AVMediaTypeVideo).first!

    // When thinking about the following code, think of capturing video in landscape!
    // e.g. videoTrack.naturalSize.height is the width if you are holding the phone portrait
    let videoComposition = AVMutableVideoComposition()
    videoComposition.renderSize = CGSize(width: videoTrack.naturalSize.height, height: videoTrack.naturalSize.height)
    videoComposition.frameDuration = CMTimeMake(1, FPS) // 24 FPS

    let instruction = AVMutableVideoCompositionInstruction()
    instruction.timeRange = CMTimeRangeMake(kCMTimeZero, asset.duration)

    let transformer = AVMutableVideoCompositionLayerInstruction(assetTrack: videoTrack)

    // Crop to middle of the view
    // http://www.one-dreamer.com/cropping-video-square-like-vine-instagram-xcode/
    let initialTransform = CGAffineTransform(translationX: videoTrack.naturalSize.height, y: -(videoTrack.naturalSize.width - videoTrack.naturalSize.height) / 2 )
    let transform = initialTransform.rotated(by: CGFloat(Double.pi / 2))

    transformer.setTransform(transform, at: kCMTimeZero)
    instruction.layerInstructions = [transformer]
    videoComposition.instructions = [instruction]

    let randomString = UUID().uuidString
    let exportedVideoURL = outputFileURL.deletingLastPathComponent().appendingPathComponent("video_\(randomString).mp4")
    let exportedThumbnailURL = exportedVideoURL.deletingLastPathComponent().appendingPathComponent("image_\(randomString).jpg")

    // Export
    do { try FileManager.default.removeItem(at: outputFileURL) } catch { }
    do { try FileManager.default.removeItem(at: exportedVideoURL) } catch { }
    do { try FileManager.default.removeItem(at: exportedThumbnailURL) } catch { }

    let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
    exporter.videoComposition = videoComposition
    exporter.outputURL = exportedVideoURL
    exporter.outputFileType = AVFileTypeMPEG4
    exporter.exportAsynchronously {
      let asset = AVURLAsset(url: exportedVideoURL, options: nil)
      let imageGenerator = AVAssetImageGenerator(asset: asset)
      let imageRef = try! imageGenerator.copyCGImage(at: kCMTimeZero, actualTime: nil)
      let thumbnailData = UIImageJPEGRepresentation(UIImage(cgImage: imageRef), 1)!
      try? thumbnailData.write(to: exportedThumbnailURL, options: [.atomic])
      DispatchQueue.main.async {
        self.resetProgressViewAnimation()
        self.previewVideo(exporter.outputURL!)
        self.delegate?.videoDidEndRecordingToFileAtURL(exporter.outputURL!, thumbnailURL: exportedThumbnailURL)
      }
    }
  }
}

// MARK: - CameraViewControllerDelegate
protocol CameraViewControllerDelegate {
  func videoDidBeginRecording()
  func videoDidEndRecordingToFileAtURL(_ videoURL: URL, thumbnailURL: URL)
  func videoPreviewDidCancel()
}

// MARK: - CameraViewControllerState
enum CameraViewControllerState {
  case `default`, recording, previewing
}
