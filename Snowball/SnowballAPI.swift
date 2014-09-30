//
//  SnowballAPI.swift
//  Snowball
//
//  Created by James Martinez on 9/29/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

func APIRequest(URLRequest: URLRequestConvertible) -> Request {
  return Alamofire.request(URLRequest)
}

enum Router: URLRequestConvertible {
  static let baseURLString = "http://snowball-staging.herokuapp.com/api/v1/"

  // Authentication
  case SignUp(username: String, email: String, password: String)
  case SignIn(email: String, password: String)
  // User
  case GetCurrentUser
  case UpdateCurrentUser(username: String?, email: String?, name: String?)
  case GetCurrentUserFollowing
  case FollowUser(userID: String)
  case UnfollowUser(userID: String)
  case FindUsersByPhoneNumbers(phoneNumbers: [String])
  // Reel
  case GetReelStream
  case CreateReel(title: String?, participantIDs: [String]?)
  case UpdateReelTitle(reelID: String, title: String)
  case GetReelParticipants(reelID: String)
  case AddParticipantToReel(reelID: String, userID: String)
  case RemoveCurrentUserAsParticipantInReel(reelID: String)
  // Clip
  case GetUnwatchedClipsInReel(reelID: String, since: NSDate?)
  case CreateClipInReel(reelID: String, videoData: NSData)

  var method: Alamofire.Method {
    switch self {
      case .SignUp: return .POST
      case .SignIn: return .POST
      case .GetCurrentUser: return .GET
      case .UpdateCurrentUser: return .PATCH
      case .GetCurrentUserFollowing: return .GET
      case .FollowUser: return .POST
      case .UnfollowUser: return .DELETE
      case .FindUsersByPhoneNumbers: return .POST
      case .GetReelStream: return .GET
      case .CreateReel: return .POST
      case .UpdateReelTitle: return .PATCH
      case .GetReelParticipants: return .GET
      case .AddParticipantToReel: return .POST
      case .RemoveCurrentUserAsParticipantInReel: return .DELETE
      case .GetUnwatchedClipsInReel: return .GET
      case .CreateClipInReel: return .POST
    }
  }

  var path: String {
    switch self {
      case .SignUp: return "users/sign_up"
      case .SignIn: return "users/sign_in"
      case .GetCurrentUser: return "users/me"
      case .UpdateCurrentUser: return "users/me"
      case .GetCurrentUserFollowing: return "users/me/following"
      case .FollowUser(let userID): return "users/\(userID)/following"
      case .UnfollowUser(let userID): return "users/\(userID)/unfollow"
      case .FindUsersByPhoneNumbers: return "users/find_by_contacts"
      case .GetReelStream: return "reels/stream"
      case .CreateReel: return "reels"
      case .UpdateReelTitle(let reelID, _): return "reels/\(reelID)"
      case .GetReelParticipants(let reelID): return "reels/\(reelID)/participants"
      case .AddParticipantToReel(let reelID, let userID): return "reels/\(reelID)/participants/\(userID)"
      case .RemoveCurrentUserAsParticipantInReel(let reelID): return "reels/\(reelID)/participants/me"
      case .GetUnwatchedClipsInReel(let reelID, _): return "reels/\(reelID)/clips"
      case .CreateClipInReel(let reelID, _): return "reels/\(reelID)/clips"
    }
  }

  var parameterEncoding: ParameterEncoding? {
    switch self {
      case .SignUp: return ParameterEncoding.JSON
      case .SignIn: return ParameterEncoding.JSON
      case .UpdateCurrentUser: return ParameterEncoding.JSON
      case .FindUsersByPhoneNumbers: return ParameterEncoding.JSON
      case .CreateReel: return ParameterEncoding.JSON
      case .UpdateReelTitle: return ParameterEncoding.JSON
      case .GetUnwatchedClipsInReel: return ParameterEncoding.URL
      case .CreateClipInReel: return ParameterEncoding.JSON
      default: return nil
    }
  }

  var parameters: [String: AnyObject]? {
    switch self {
      case .SignUp(let username, let email, let password): return ["user": ["username": username, "email": email, "password": password]]
      case .SignIn(let email, let password): return ["user": ["email": email, "password": password]]
      case .UpdateCurrentUser(let username, let email, let name):
        var userParameters = [String: String]()
        if let newUsername = username {
          userParameters["username"] = newUsername
        }
        if let newEmail = email {
          userParameters["email"] = newEmail
        }
        if let newName = name {
          userParameters["name"] = newName
        }
        return ["user": userParameters]
      case .FindUsersByPhoneNumbers(let phoneNumbers):
        var contacts = [AnyObject]()
        for phoneNumber in phoneNumbers as [String] {
          contacts.append(["phone_number": phoneNumber])
        }
        return ["contacts": contacts]
      case .CreateReel(let title, let participantIDs):
        var reelParameters = [String: AnyObject]()
        if let newTitle = title {
          reelParameters["title"] = newTitle
        }
        if let newParticipantIDs = participantIDs {
          reelParameters["participant_ids"] = newParticipantIDs
        }
        return ["reel": reelParameters]
      case .UpdateReelTitle(let reelID, let title): return ["reel": ["title": title]]
      case .GetUnwatchedClipsInReel(let reelID, let since):
        var parameters = [String: AnyObject]()
        if let sinceDate = since {
          parameters["since"] = Int(sinceDate.timeIntervalSince1970)
        }
        return parameters
      case .CreateClipInReel(let reelID, let videoData): return ["clip": ["video": NSString(data: videoData, encoding: NSUTF8StringEncoding)]]
      default: return nil
    }
  }

  // MARK: URLRequestConvertible

  var URLRequest: NSURLRequest {
    let URL = NSURL(string: Router.baseURLString)
    let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
    mutableURLRequest.HTTPMethod = method.toRaw()

    if let authToken = APICredential.authToken {
      let encodedAuthToken = "\(authToken):".encodedAsBase64()
      mutableURLRequest.setValue("Basic \(encodedAuthToken)", forHTTPHeaderField: "Authorization")
    }
    if let encoding = parameterEncoding {
      return encoding.encode(mutableURLRequest, parameters: parameters).0
    }
    return mutableURLRequest
  }
}

struct APICredential {
  static let kCurrentUserAuthTokenKey = "CurrentUserAuthToken"
  static var authToken: String? {
    get {
    return NSUserDefaults.standardUserDefaults().objectForKey(kCurrentUserAuthTokenKey) as String?
    }
    set {
      if let authToken = newValue {
        NSUserDefaults.standardUserDefaults().setObject(authToken, forKey: kCurrentUserAuthTokenKey)
      } else {
        NSUserDefaults.standardUserDefaults().removeObjectForKey(kCurrentUserAuthTokenKey)
      }
      NSUserDefaults.standardUserDefaults().synchronize()
    }
  }
}

// MARK: Serialization
// https://github.com/Alamofire/Alamofire#generic-response-object-serialization

protocol JSONObjectSerializable: class {
  init(JSON: [String: AnyObject])
}

protocol JSONArraySerializable: class {
  class func arrayFromJSON(JSON: [String: AnyObject]) -> [AnyObject]
}

extension Alamofire.Request {
  func responseObject<T: JSONObjectSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
    let serializer: Serializer = { (request, response, data) in
      let JSONSerializer = Request.JSONResponseSerializer()
      let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
      if response != nil && JSON != nil {
        let object: AnyObject = T(JSON: JSON as [String: AnyObject]) as AnyObject
        RLMRealm.defaultRealm().beginWriteTransaction()
        RLMRealm.defaultRealm().addObject(object as RLMObject)
        RLMRealm.defaultRealm().commitWriteTransaction()
        return (object, nil)
      }
      return (nil, serializationError)
    }
    return response(serializer: serializer) { (request, response, object, error) in
      completionHandler(request, response, object as? T, error)
    }
  }

  func responseObjects<T: JSONArraySerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, NSError?) -> Void) -> Self {
    let serializer: Serializer = { (request, response, data) in
      let JSONSerializer = Request.JSONResponseSerializer()
      let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
      if response != nil && JSON != nil {
        let objects = T.arrayFromJSON(JSON as [String: AnyObject])
        RLMRealm.defaultRealm().beginWriteTransaction()
        RLMRealm.defaultRealm().addObjectsFromArray(objects)
        RLMRealm.defaultRealm().commitWriteTransaction()
        return (objects, nil)
      }
      return (nil, serializationError)
    }
    return response(serializer: serializer) { (request, response, objects, error) in
      completionHandler(request, response, objects as? [T], error)
    }
  }
}