//
//  TimelineViewController.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Alamofire
import UIKit

class TimelineViewController: UIViewController {
  var clips = [Clip]()
  let player = TimelinePlayer()
  let playerView = PlayerView()

  override func viewDidLoad() {
    super.viewDidLoad()

    SnowballAPI.request(SnowballAPIRoute.ClipStream).responseCollection { (response: Response<[Clip], NSError>) in
      switch response.result {
      case .Success(let clips):
        self.clips = clips
        self.player.playClip(self.clips.first!)
      case .Failure(let error): debugPrint(error)
      }
    }

    view.backgroundColor = UIColor.whiteColor()

    player.dataSource = self
    player.delegate = self

    view.addSubview(playerView)
    playerView.translatesAutoresizingMaskIntoConstraints = false
    playerView.leftAnchor.constraintEqualToAnchor(view.leftAnchor).active = true
    playerView.topAnchor.constraintEqualToAnchor(view.topAnchor).active = true
    playerView.rightAnchor.constraintEqualToAnchor(view.rightAnchor).active = true
    playerView.bottomAnchor.constraintEqualToAnchor(view.centerYAnchor).active = true

    playerView.player = player
  }
}

// MARK: - TimelinePlayerDataSource
extension TimelineViewController: TimelinePlayerDataSource {
  func numberOfClipsInTimelinePlayer(player: TimelinePlayer) -> Int {
    return clips.count
  }

  func timelinePlayer(player: TimelinePlayer, clipAtIndex index: Int) -> Clip {
    return clips[index]
  }

  func timelinePlayer(player: TimelinePlayer, indexOfClip clip: Clip) -> Int? {
    return clips.indexOf(clip)
  }
}

// MARK: - TimelinePlayerDeleate
extension TimelineViewController: TimelinePlayerDelegate {
  func timelinePlayer(timelinePlayer: TimelinePlayer, willBeginPlaybackWithFirstClip clip: Clip) {
    print("begin")
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didTransitionFromClip fromClip: Clip, toClip: Clip) {
    print("transition")
  }

  func timelinePlayer(timelinePlayer: TimelinePlayer, didEndPlaybackWithLastClip clip: Clip) {
    print("done")
  }
}