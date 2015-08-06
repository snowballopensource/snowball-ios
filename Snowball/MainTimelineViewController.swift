//
//  MainTimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 7/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Cartography
import UIKit

class MainTimelineViewController: TimelineViewController {
  let cameraViewController = CameraViewController()

  // MARK: - UIViewController

  override func viewDidLoad() {
    super.viewDidLoad()

    cameraViewController.delegate = self
  }

  override func loadView() {
    super.loadView()

    addChildViewController(cameraViewController)
    view.addSubview(cameraViewController.view)
    cameraViewController.didMoveToParentViewController(self)
    layout(cameraViewController.view) { (cameraView) in
      cameraView.left == cameraView.superview!.left
      cameraView.top == cameraView.superview!.top
      cameraView.right == cameraView.superview!.right
      cameraView.height == cameraView.width
    }
  }

  // MARK: - TimelineViewController

  override func refresh() {
    timeline.requestHomeTimeline { (error) -> Void in
      if let error = error {
        println(error)
        // TODO: Display the error
      }
    }
  }

  override func stateForCellAtIndexPath(indexPath: NSIndexPath) -> ClipCollectionViewCellState {
    let superState = super.stateForCellAtIndexPath(indexPath)
    if superState != ClipCollectionViewCellState.Default {
      return superState
    }
    let clip = timeline.clips[indexPath.row]
    if let bookmarkedClip = timeline.bookmarkedClip {
      if clip == bookmarkedClip {
        return ClipCollectionViewCellState.Bookmarked
      }
    }
    return superState
  }
}

// MARK: - TimelineDelegate
extension MainTimelineViewController: TimelineDelegate {

  override func timelineClipsDidLoad() {
    super.timelineClipsDidLoad()

    if let pendingClip = timeline.pendingClips.last {
      scrollToClip(pendingClip, animated: false)
    } else if let bookmarkedClip = timeline.bookmarkedClip {
      scrollToClip(bookmarkedClip, animated: false)
    }
  }
}

extension MainTimelineViewController: CameraViewControllerDelegate {

  func videoDidBeginRecording() {

  }

  func videoDidEndRecordingToFileAtURL(videoURL: NSURL, thumbnailURL: NSURL) {
    let clip = Clip()
    clip.state = ClipState.PendingUpload
    clip.videoURL = videoURL
    clip.thumbnailURL = thumbnailURL
    clip.user = User.currentUser
    clip.createdAt = NSDate()
    timeline.appendClip(clip)
    scrollToClip(clip, animated: true)
  }

  func videoPreviewDidCancel() {
    if let clip = timeline.pendingClips.last {
      timeline.deleteClip(clip)
    }
  }
}