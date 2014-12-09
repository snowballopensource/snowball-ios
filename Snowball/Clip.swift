//
//  Clip.swift
//  Snowball
//
//  Created by James Martinez on 12/6/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import CoreData

class Clip: RemoteObject {
  @NSManaged var id: String
  @NSManaged var videoURL: String
  @NSManaged var createdAt: NSDate
  @NSManaged var user: User
}