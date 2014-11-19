//
//  CaptureSessionController.swift
//  Snowball
//
//  Created by James Martinez on 9/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AVFoundation
import Foundation

protocol CaptureSessionControllerDelegate: class {
  func movieRecordedToFileAtURL(fileURL: NSURL, error: NSError?)
}

class CaptureSessionController: NSObject, AVCaptureFileOutputRecordingDelegate {
  let captureSession = AVCaptureSession()
  var delegate: CaptureSessionControllerDelegate?
  private var currentVideoDeviceInput: AVCaptureDeviceInput?
  private var movieFileOutput: AVCaptureMovieFileOutput?
  private var sessionQueue: dispatch_queue_t

  override init() {
    sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL)
    super.init()
    captureSession.sessionPreset = AVCaptureSessionPreset640x480
    checkDeviceAuthorizationStatus { (granted) in
      let videoDevice = self.captureDevice(mediaType: AVMediaTypeVideo, position: AVCaptureDevicePosition.Front)
      let videoDeviceInput = AVCaptureDeviceInput(device: videoDevice, error: nil)
      if self.captureSession.canAddInput(videoDeviceInput) {
        self.captureSession.addInput(videoDeviceInput)
        self.currentVideoDeviceInput = videoDeviceInput
      }
      let audioDevice = self.captureDevice(mediaType: AVMediaTypeAudio)
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
  }

  func captureDevice(#mediaType: String, position: AVCaptureDevicePosition? = nil) -> AVCaptureDevice? {
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

  func checkDeviceAuthorizationStatus(completionHandler: (Bool) -> ()) {
    AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: { (granted) in
      completionHandler(granted)
    })
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
      if let newDevice = captureDevice(mediaType: AVMediaTypeVideo, position: newPosition) {
        var error: NSError?
        let newDeviceInput = AVCaptureDeviceInput(device: newDevice, error: &error)
        captureSession.beginConfiguration()
        captureSession.removeInput(currentVideoDeviceInput)
        if captureSession.canAddInput(newDeviceInput) {
          captureSession.addInput(newDeviceInput)
          currentVideoDeviceInput = newDeviceInput
        }
      }
    }
  }

  func startSession() {
    Async.customQueue(sessionQueue) {
      self.captureSession.startRunning()
    }
  }

  func stopSession() {
    Async.customQueue(sessionQueue) {
      self.captureSession.stopRunning()
    }
  }

  func beginRecording() {
    Async.customQueue(sessionQueue) {
      if let recording = self.movieFileOutput?.recording {
        if !recording {
          let outputFileName = "movie".stringByAppendingPathExtension("mov")!
          let outputFilePath = NSTemporaryDirectory().stringByAppendingPathComponent(outputFileName)
          self.movieFileOutput?.startRecordingToOutputFileURL(NSURL(fileURLWithPath: outputFilePath), recordingDelegate: self)
        }
      }
    }
  }

  func endRecording() {
    Async.customQueue(sessionQueue) {
      if let recording = self.movieFileOutput?.recording {
        if recording {
          self.movieFileOutput?.stopRecording()
        }
      }
    }
  }

  // MARK: AVCaptureFileOutputRecordingDelegate

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

    // Remove existing file (to be replaced with transformed file during export)
    NSFileManager.defaultManager().removeItemAtURL(outputFileURL, error: nil)

    // Export
    let exporter = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality)
    exporter.videoComposition = videoComposition
    exporter.outputURL = outputFileURL
    exporter.outputFileType = AVFileTypeMPEG4
    exporter.exportAsynchronouslyWithCompletionHandler { () -> Void in
      if let delegate = self.delegate {
        Async.main {
          delegate.movieRecordedToFileAtURL(outputFileURL, error: error)
        }
      }
    }
  }
}