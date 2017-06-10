//
//  HomeTimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 2/17/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Cartography
import Foundation
import UIKit

class HomeTimelineViewController: TimelineViewController {

  // MARK: Properties

  let cameraViewController = CameraViewController()

  // MARK: Initializers

  init() {
    super.init(timelineType: .home)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-flip-camera"), style: .plain, target: self, action: #selector(HomeTimelineViewController.rightBarButtonItemPressed))

    addChildViewController(cameraViewController)
    view.addSubview(cameraViewController.view)
    constrain(cameraViewController.view) { cameraView in
      cameraView.left == cameraView.superview!.left
      cameraView.top == cameraView.superview!.top
      cameraView.right == cameraView.superview!.right
      cameraView.height == cameraView.superview!.width
    }
    cameraViewController.didMove(toParentViewController: self)
    cameraViewController.delegate = self
  }

  // MARK: Private

  fileprivate func tryUploadingClip(_ clip: Clip) {
    state = .default
    SnowballAPI.queueClipForUploadingAndHandleStateChanges(clip) { (response) -> Void in
      switch response {
      case .success: break
      case .failure(let error): print(error) // TODO: Handle error
      }
    }
  }

  // MARK: Actions

  @objc fileprivate func rightBarButtonItemPressed() {
    cameraViewController.changeCamera()
  }

  // MARK: TimelinePlayerDelegate Overrides
  // This is because swift does not allow overrides in extensions. Sorry!

  override func timelinePlayer(_ timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip) {
    super.timelinePlayer(timelinePlayer, willBeginPlaybackWithFirstClip: clip)
    view.sendSubview(toBack: cameraViewController.view)
  }

  override func timelinePlayer(_ timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
    super.timelinePlayer(timelinePlayer, didEndPlaybackWithLastClip: clip)
    view.bringSubview(toFront: cameraViewController.view)
  }

  // MARK: ClipCollectionViewCellDelegate Overrides
  // This is because swift does not allow overrides in extensions. Sorry!

  override func clipCollectionViewCellAddButtonTapped(_ cell: ClipCollectionViewCell) {
    state = .default
    super.clipCollectionViewCellAddButtonTapped(cell)
    guard let clip = clipForCell(cell) else { return }
    cameraViewController.endPreview()
    tryUploadingClip(clip)
  }

  override func clipCollectionViewCellRetryUploadButtonTapped(_ cell: ClipCollectionViewCell) {
    super.clipCollectionViewCellRetryUploadButtonTapped(cell)
    guard let clip = clipForCell(cell) else { return }
    tryUploadingClip(clip)
  }
}

// MARK: - CameraViewControllerDelegate
extension TimelineViewController: CameraViewControllerDelegate {
  func videoDidBeginRecording() {
    state = .recording
  }

  func videoDidEndRecordingToFileAtURL(_ videoURL: URL, thumbnailURL: URL) {
    state = .previewing
    let clip = Clip()
    clip.state = .PendingAcceptance
    clip.timelineID = timeline.id
    clip.inHomeTimeline = true
    clip.videoURL = videoURL.absoluteString
    clip.thumbnailURL = thumbnailURL.absoluteString
    clip.user = User.currentUser
    Database.performTransaction {
      Database.save(clip)
    }
    scrollToCellForClip(clip, animated: true)
  }

  func videoPreviewDidCancel() {
    state = .default
    if let pendingClip = timeline.clipPendingAcceptance {
      Database.performTransaction {
        Database.delete(pendingClip)
      }
    }
  }
}
