//
//  SnowballRoute.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

enum SnowballRoute: URLRequestConvertible {
  // Authentication
  case SignUp(username: String, email: String, password: String)
  case SignIn(email: String, password: String)
  // User
  case GetCurrentUser
  case UpdateCurrentUser(username: String?, email: String?, phoneNumber: String?)
  case UploadCurrentUserAvatar
  case GetCurrentUserFollowers
  case GetCurrentUserFollowing
  case FollowUser(userID: String)
  case UnfollowUser(userID: String)
  case FindUsersByPhoneNumbers(phoneNumbers: [String])
  case FindUsersByUsername(username: String)
  case FindFriendsOfFriends
  // Device
  case RegisterForPushNotifications(token: String)
  // Clip
  case GetClipStream(page: Int)
  case GetClipStreamForUser(userID: String, page: Int)
  case DeleteClip(clipID: String)
  case LikeClip(clipID: String)
  case UnlikeClip(clipID: String)
  case FlagClip(clipID: String)
  case UploadClip

  // MARK: Properties

  static let baseURLString: String = {
//    return "https://api.snowball.is/v1/"
    return "https://snowball-api.herokuapp.com/v1"
  }()

  private var method: Alamofire.Method {
    switch self {
    case .SignUp: return .POST
    case .SignIn: return .POST
    case .GetCurrentUser: return .GET
    case .UpdateCurrentUser: return .PATCH
    case .UploadCurrentUserAvatar: return .PATCH
    case .GetCurrentUserFollowers: return .GET
    case .GetCurrentUserFollowing: return .GET
    case .FollowUser: return .POST
    case .UnfollowUser: return .DELETE
    case .FindUsersByPhoneNumbers: return .POST
    case .FindUsersByUsername: return .POST
    case .FindFriendsOfFriends: return .GET
    case .RegisterForPushNotifications: return .POST
    case .GetClipStream: return .GET
    case .GetClipStreamForUser: return .GET
    case .DeleteClip: return .DELETE
    case .LikeClip: return .POST
    case .UnlikeClip: return .DELETE
    case .FlagClip: return .POST
    case .UploadClip: return .POST
    }
  }

  private var path: String {
    switch self {
    case .SignUp: return "users/sign-up"
    case .SignIn: return "users/sign-in"
    case .GetCurrentUser: return "users/me"
    case .UpdateCurrentUser: return "users/me"
    case .UploadCurrentUserAvatar: return "/users/me"
    case .GetCurrentUserFollowers: return "users/\(User.currentUser!.id!)/followers"
    case .GetCurrentUserFollowing: return "users/\(User.currentUser!.id!)/following"
    case .FollowUser(let userID): return "users/\(userID)/follow"
    case .UnfollowUser(let userID): return "users/\(userID)/follow"
    case .FindUsersByPhoneNumbers: return "users/search"
    case .FindUsersByUsername: return "users/search"
    case .FindFriendsOfFriends: return "users/friends-of-friends"
    case .RegisterForPushNotifications: return "installations"
    case .GetClipStream: return "clips/stream"
    case .GetClipStreamForUser(let userID, _): return "users/\(userID)/clips/stream"
    case .DeleteClip(let clipID): return "clips/\(clipID)"
    case .LikeClip(let clipID): return "clips/\(clipID)/like"
    case .UnlikeClip(let clipID): return "clips/\(clipID)/like"
    case .FlagClip(let clipID): return "clips/\(clipID)/flag"
    case .UploadClip: return "clips"
    }
  }

  private var parameterEncoding: ParameterEncoding? {
    switch self {
    case .SignUp: return ParameterEncoding.JSON
    case .SignIn: return ParameterEncoding.JSON
    case .UpdateCurrentUser: return ParameterEncoding.JSON
    case .FindUsersByPhoneNumbers: return ParameterEncoding.JSON
    case .FindUsersByUsername: return ParameterEncoding.JSON
    case .RegisterForPushNotifications: return .JSON
    case .GetClipStream: return ParameterEncoding.URL
    case .GetClipStreamForUser: return ParameterEncoding.URL
    default: return nil
    }
  }

  private var parameters: [String: AnyObject]? {
    switch self {
    case .SignUp(let username, let email, let password): return ["username": username, "email": email, "password": password]
    case .SignIn(let email, let password): return ["email": email, "password": password]
    case .UpdateCurrentUser(let username, let email, let phoneNumber):
      var userParameters = [String: String]()
      if let newUsername = username {
        userParameters["username"] = newUsername
      }
      if let newEmail = email {
        userParameters["email"] = newEmail
      }
      if let newPhoneNumber = phoneNumber {
        userParameters["phone_number"] = newPhoneNumber
      }
      return userParameters
    case .FindUsersByPhoneNumbers(let phoneNumbers): return ["phone_numbers": phoneNumbers]
    case .FindUsersByUsername(let username): return ["username": username]
    case .RegisterForPushNotifications(let token):
      var pushParameters: [String: AnyObject] = ["platform": 0, "token": token]
      if isDebug() {
        pushParameters["development"] = true
      }
      return pushParameters
    case .GetClipStream(let page): return ["page": page]
    case .GetClipStreamForUser(_, let page): return ["page": page]
    default: return nil
    }
  }

  // MARK: URLRequestConvertible

  var URLRequest: NSMutableURLRequest {
    let URL = NSURL(string: SnowballRoute.baseURLString)
    let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
    mutableURLRequest.HTTPMethod = method.rawValue
    if let authToken = User.currentUser?.authToken {
      let encodedAuthTokenData = "\(authToken):".dataUsingEncoding(NSUTF8StringEncoding)!
      let encodedAuthToken = encodedAuthTokenData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
      mutableURLRequest.setValue("Basic \(encodedAuthToken)", forHTTPHeaderField: "Authorization")
    }
    if let params = parameters {
      return parameterEncoding!.encode(mutableURLRequest, parameters: params).0
    }
    return mutableURLRequest
  }
}