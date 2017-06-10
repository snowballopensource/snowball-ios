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

  fileprivate var method: Alamofire.HTTPMethod {
    switch self {
    case .signUp: return .post
    case .signIn: return .post
    case .getCurrentUser: return .get
    case .updateCurrentUser: return .patch
    case .uploadCurrentUserAvatar: return .patch
    case .getCurrentUserFollowers: return .get
    case .getCurrentUserFollowing: return .get
    case .followUser: return .put
    case .unfollowUser: return .delete
    case .findUsersByPhoneNumbers: return .post
    case .findUsersByUsername: return .post
    case .findRecommendedUsers: return .get
    case .registerForPushNotifications: return .put
    case .getClipStream: return .get
    case .getClipStreamForUser: return .get
    case .deleteClip: return .delete
    case .likeClip: return .put
    case .unlikeClip: return .delete
    case .flagClip: return .put
    case .uploadClip: return .post
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
    case .signUp: return JSONEncoding.default
    case .signIn: return JSONEncoding.default
    case .updateCurrentUser: return JSONEncoding.default
    case .findUsersByPhoneNumbers: return JSONEncoding.default
    case .findUsersByUsername: return JSONEncoding.default
    case .registerForPushNotifications: return JSONEncoding.default
    case .getClipStream: return URLEncoding.default
    case .getClipStreamForUser: return URLEncoding.default
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

  func asURLRequest() -> URLRequest {
    let url = URL(string: SnowballRoute.baseURLString)
    var urlRequest = URLRequest(url: url!.appendingPathComponent(path))
    urlRequest.httpMethod = method.rawValue
    if let authToken = User.currentUser?.authToken {
      let encodedAuthTokenData = "\(authToken):".data(using: String.Encoding.utf8)!
      let encodedAuthToken = encodedAuthTokenData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
      urlRequest.setValue("Basic \(encodedAuthToken)", forHTTPHeaderField: "Authorization")
    }
    if let params = parameters, let parameterEncoding = parameterEncoding {
      urlRequest = try! parameterEncoding.encode(urlRequest, with: params)
    }
    return urlRequest
  }
}
