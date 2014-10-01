//
//  APIImporter.swift
//  Snowball
//
//  Created by James Martinez on 9/30/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

struct APIImporter {
  typealias CompletionHandler = (NSError?) -> ()

  static func importJSONFromRoute(route: APIRouter, JSON: [String: AnyObject], completionHandler: CompletionHandler?) {
    let importDirections = APIImportDirections(route: route)

    // TODO: import the JSON

    if let completion = completionHandler {
      completion(nil)
    }
  }
}

enum JSONDataType {
  case Object
  case Array
}

enum APIImportMethod {
  case AuthToken
  case PersistToDisk
}

struct APIImportDirections {
  let importMethod: APIImportMethod
  let dataType: JSONDataType
  let key: String

  init(route: APIRouter) {
    switch route {
      case .SignUp: importMethod = .AuthToken; dataType = .Object; key = "auth_token"
      case .SignIn: importMethod = .AuthToken; dataType = .Object; key = "auth_token"
      case .GetCurrentUser: importMethod = .PersistToDisk; dataType = .Object; key = "user"
      case .UpdateCurrentUser: importMethod = .PersistToDisk; dataType = .Object; key = "user"
      case .GetCurrentUserFollowing: importMethod = .PersistToDisk; dataType = .Array; key = "users"
      case .FollowUser: importMethod = .PersistToDisk; dataType = .Object; key = "user"
      case .UnfollowUser: importMethod = .PersistToDisk; dataType = .Object; key = "user"
      case .FindUsersByPhoneNumbers: importMethod = .PersistToDisk; dataType = .Array; key = "users"
      case .GetReelStream: importMethod = .PersistToDisk; dataType = .Array; key = "reels"
      case .CreateReel: importMethod = .PersistToDisk; dataType = .Object; key = "ree;"
      case .UpdateReelTitle: importMethod = .PersistToDisk; dataType = .Object; key = "reel"
      case .GetReelParticipants: importMethod = .PersistToDisk; dataType = .Array; key = "users"
      case .AddParticipantToReel: importMethod = .PersistToDisk; dataType = .Object; key = "user"
      case .RemoveCurrentUserAsParticipantInReel: importMethod = .PersistToDisk; dataType = .Object; key = "user"
      case .GetUnwatchedClipsInReel: importMethod = .PersistToDisk; dataType = .Array; key = "clips"
      case .CreateClipInReel: importMethod = .PersistToDisk; dataType = .Object; key = "clip"
    }
  }
}