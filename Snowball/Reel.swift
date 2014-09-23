//
//  Reel.swift
//  Snowball
//
//  Created by James Martinez on 9/22/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

class Reel: RLMObject {
  dynamic var id = ""
  dynamic var title = ""
  dynamic var participantsTitle = ""

  dynamic var clips = RLMArray(objectClassName: Clip.className())
  dynamic var participants = RLMArray(objectClassName: User.className())

  // MARK: RLMObject

  override func updateFromDictionary(dictionary: [String: AnyObject]) {
    if let id = dictionary["id"] as AnyObject? as? String {
      self.id = id
    }
    if let title = dictionary["title"] as AnyObject? as? String {
      self.title = title
    }
    if let participantsTitle = dictionary["participants_title"] as AnyObject? as? String {
      self.participantsTitle = participantsTitle
    }
//    if let lastClipDictionary = dictionary["last_clip"] as AnyObject? as [String: AnyObject]? {
//      Clip.importFromDictionary(lastClipDictionary, inRealm: self.realm)
//    }
  }
}