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
  case signUp(username: String, email: String, password: String)
  case signIn(email: String, password: String)
  // User
  case getCurrentUser
  case updateCurrentUser(username: String?, email: String?, phoneNumber: String?)
  case uploadCurrentUserAvatar
  case getCurrentUserFollowers
  case getCurrentUserFollowing
  case followUser(userID: String)
  case unfollowUser(userID: String)
  case findUsersByPhoneNumbers(phoneNumbers: [String])
  case findUsersByUsername(username: String)
  case findRecommendedUsers
  // Device
  case registerForPushNotifications(token: String)
  // Clip
  case getClipStream(page: Int)
  case getClipStreamForUser(userID: String, page: Int)
  case deleteClip(clipID: String)
  case likeClip(clipID: String)
  case unlikeClip(clipID: String)
  case flagClip(clipID: String)
  case uploadClip

  // MARK: Properties

  static let baseURLString: String = {
    return "https://api.snowball.is/v1/"
  }()

  fileprivate var method: Alamofire.Method {
    switch self {
    case .signUp: return .POST
    case .signIn: return .POST
    case .getCurrentUser: return .GET
    case .updateCurrentUser: return .PATCH
    case .uploadCurrentUserAvatar: return .PATCH
    case .getCurrentUserFollowers: return .GET
    case .getCurrentUserFollowing: return .GET
    case .followUser: return .PUT
    case .unfollowUser: return .DELETE
    case .findUsersByPhoneNumbers: return .POST
    case .findUsersByUsername: return .POST
    case .findRecommendedUsers: return .GET
    case .registerForPushNotifications: return .PUT
    case .getClipStream: return .GET
    case .getClipStreamForUser: return .GET
    case .deleteClip: return .DELETE
    case .likeClip: return .PUT
    case .unlikeClip: return .DELETE
    case .flagClip: return .PUT
    case .uploadClip: return .POST
    }
  }

  fileprivate var path: String {
    switch self {
    case .signUp: return "users/sign-up"
    case .signIn: return "users/sign-in"
    case .getCurrentUser: return "users/\(User.currentUser!.id!)"
    case .updateCurrentUser: return "users/me"
    case .uploadCurrentUserAvatar: return "/users/me"
    case .getCurrentUserFollowers: return "users/\(User.currentUser!.id!)/followers"
    case .getCurrentUserFollowing: return "users/\(User.currentUser!.id!)/following"
    case .followUser(let userID): return "users/\(userID)/follow"
    case .unfollowUser(let userID): return "users/\(userID)/follow"
    case .findUsersByPhoneNumbers: return "users/search"
    case .findUsersByUsername: return "users/search"
    case .findRecommendedUsers: return "users/recommended"
    case .registerForPushNotifications: return "installations"
    case .getClipStream: return "clips/stream"
    case .getClipStreamForUser(let userID, _): return "users/\(userID)/clips/stream"
    case .deleteClip(let clipID): return "clips/\(clipID)"
    case .likeClip(let clipID): return "clips/\(clipID)/like"
    case .unlikeClip(let clipID): return "clips/\(clipID)/like"
    case .flagClip(let clipID): return "clips/\(clipID)/flag"
    case .uploadClip: return "clips"
    }
  }

  fileprivate var parameterEncoding: ParameterEncoding? {
    switch self {
    case .signUp: return ParameterEncoding.JSON
    case .signIn: return ParameterEncoding.JSON
    case .updateCurrentUser: return ParameterEncoding.JSON
    case .findUsersByPhoneNumbers: return ParameterEncoding.JSON
    case .findUsersByUsername: return ParameterEncoding.JSON
    case .registerForPushNotifications: return .JSON
    case .getClipStream: return ParameterEncoding.URL
    case .getClipStreamForUser: return ParameterEncoding.URL
    default: return nil
    }
  }

  fileprivate var parameters: [String: AnyObject]? {
    switch self {
    case .signUp(let username, let email, let password): return ["username": username as AnyObject, "email": email as AnyObject, "password": password as AnyObject]
    case .signIn(let email, let password): return ["email": email as AnyObject, "password": password as AnyObject]
    case .updateCurrentUser(let username, let email, let phoneNumber):
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
      return userParameters as [String : AnyObject]
    case .findUsersByPhoneNumbers(let phoneNumbers): return ["phone_numbers": phoneNumbers as AnyObject]
    case .findUsersByUsername(let username): return ["username": username as AnyObject]
    case .registerForPushNotifications(let token): return ["token": token as AnyObject]
    case .getClipStream(let page): return ["page": page as AnyObject]
    case .getClipStreamForUser(_, let page): return ["page": page as AnyObject]
    default: return nil
    }
  }

  // MARK: URLRequestConvertible

  var URLRequest: NSMutableURLRequest {
    let URL = Foundation.URL(string: SnowballRoute.baseURLString)
    let mutableURLRequest = NSMutableURLRequest(url: URL!.appendingPathComponent(path))
    mutableURLRequest.HTTPMethod = method.rawValue
    if let authToken = User.currentUser?.authToken {
      let encodedAuthTokenData = "\(authToken):".data(using: String.Encoding.utf8)!
      let encodedAuthToken = encodedAuthTokenData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
      mutableURLRequest.setValue("Basic \(encodedAuthToken)", forHTTPHeaderField: "Authorization")
    }
    if let params = parameters {
      return parameterEncoding!.encode(mutableURLRequest, parameters: params).0
    }
    return mutableURLRequest
  }
}
