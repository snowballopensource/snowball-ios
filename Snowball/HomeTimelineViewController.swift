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
    super.init(timelineType: .Home)
  }

  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "top-flip-camera"), style: .Plain, target: self, action: "rightBarButtonItemPressed")

    addChildViewController(cameraViewController)
    view.addSubview(cameraViewController.view)
    constrain(cameraViewController.view) { cameraView in
      cameraView.left == cameraView.superview!.left
      cameraView.top == cameraView.superview!.top
      cameraView.right == cameraView.superview!.right
      cameraView.height == cameraView.superview!.width
    }
    cameraViewController.didMoveToParentViewController(self)
    cameraViewController.delegate = self
  }

  // MARK: Private

  private func tryUploadingClip(clip: Clip) {
    state = .Default
    SnowballAPI.queueClipForUploadingAndHandleStateChanges(clip) { (response) -> Void in
      switch response {
      case .Success: break
      case .Failure(let error): print(error) // TODO: Handle error
      }
    }
  }

  // MARK: Actions

  @objc private func rightBarButtonItemPressed() {
    cameraViewController.changeCamera()
  }

  // MARK: TimelinePlayerDelegate Overrides
  // This is because swift does not allow overrides in extensions. Sorry!

  override func timelinePlayer(timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip) {
    super.timelinePlayer(timelinePlayer, willBeginPlaybackWithFirstClip: clip)
    view.sendSubviewToBack(cameraViewController.view)
  }

  override func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
    super.timelinePlayer(timelinePlayer, didEndPlaybackWithLastClip: clip)
    view.bringSubviewToFront(cameraViewController.view)
  }

  // MARK: ClipCollectionViewCellDelegate Overrides
  // This is because swift does not allow overrides in extensions. Sorry!

  override func clipCollectionViewCellAddButtonTapped(cell: ClipCollectionViewCell) {
    state = .Default
    super.clipCollectionViewCellAddButtonTapped(cell)
    guard let clip = clipForCell(cell) else { return }
    cameraViewController.endPreview()
    tryUploadingClip(clip)
  }

  override func clipCollectionViewCellRetryUploadButtonTapped(cell: ClipCollectionViewCell) {
    super.clipCollectionViewCellRetryUploadButtonTapped(cell)
    guard let clip = clipForCell(cell) else { return }
    tryUploadingClip(clip)
  }
}

// MARK: - CameraViewControllerDelegate
extension TimelineViewController: CameraViewControllerDelegate {
  func videoDidBeginRecording() {
    state = .Recording
  }

  func videoDidEndRecordingToFileAtURL(videoURL: NSURL, thumbnailURL: NSURL) {
    state = .Previewing
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
  }

  func videoPreviewDidCancel() {
    state = .Default
    if let pendingClip = timeline.clipPendingAcceptance {
      performWithoutScrollOverride {
        Database.performTransaction {
          Database.delete(pendingClip)
        }
      }
    }
  }
}