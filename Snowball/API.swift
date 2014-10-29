//
//  API.swift
//  Snowball
//
//  Created by James Martinez on 10/1/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

struct API {
  typealias CompletionHandler = (NSError?) -> ()

  // The only types of response blocks that should be used are the blocks
  // that were added in the Alamofire.Request extension at the bottom of
  // this file. These blocks provide special handling such as parsing the
  // Snowball API error into an NSError.

  static func request(URLRequest: URLRequestConvertible) -> Alamofire.Request {
    return Alamofire.request(URLRequest)
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

enum APIRoute: URLRequestConvertible {
  static let baseURLString = "http://snowball-staging.herokuapp.com/api/v1/"

  // Authentication
  case PhoneAuthentication(phoneNumber: String)
  case PhoneVerification(userID: String, phoneNumberVerificationCode: String)
  // User
  case GetCurrentUser
  case UpdateCurrentUser(name: String?, username: String?, email: String?)
  case GetCurrentUserFollowing
  case FollowUser(userID: String)
  case UnfollowUser(userID: String)
  case FindUsersByPhoneNumbers(phoneNumbers: [String])
  case FindUsersByUsername(username: String)
  // Clip
  case GetClipFeed
  case CreateClip(videoData: NSData)
  case DeleteClip(clipID: String)
  case FlagClip(clipID: String)

  var method: Alamofire.Method {
    switch self {
      case .PhoneAuthentication: return .POST
      case .PhoneVerification: return .POST
      case .GetCurrentUser: return .GET
      case .UpdateCurrentUser: return .PATCH
      case .GetCurrentUserFollowing: return .GET
      case .FollowUser: return .POST
      case .UnfollowUser: return .DELETE
      case .FindUsersByPhoneNumbers: return .GET
      case .FindUsersByUsername: return .GET
      case .GetClipFeed: return .GET
      case .CreateClip: return .POST
      case .DeleteClip: return .DELETE
      case .FlagClip: return .POST
    }
  }

  var path: String {
    switch self {
      case .PhoneAuthentication: return "users/sign_up"
      case .PhoneVerification: return "users/sign_in"
      case .GetCurrentUser: return "users/me"
      case .UpdateCurrentUser: return "users/me"
      case .GetCurrentUserFollowing: return "users/me/following"
      case .FollowUser(let userID): return "users/\(userID)/follow"
      case .UnfollowUser(let userID): return "users/\(userID)/follow"
      case .FindUsersByPhoneNumbers: return "users"
      case .FindUsersByUsername: return "users"
      case .GetClipFeed: return "clips/feed"
      case .CreateClip: return "clips"
      case .DeleteClip(let clipID): return "clips/\(clipID)"
      case .FlagClip(let clipID): return "clips/\(clipID)"
    }
  }

  var parameterEncoding: ParameterEncoding? {
    switch self {
      case .PhoneAuthentication: return ParameterEncoding.JSON
      case .PhoneVerification: return ParameterEncoding.JSON
      case .UpdateCurrentUser: return ParameterEncoding.JSON
      case .FindUsersByPhoneNumbers: return ParameterEncoding.URL
      case .FindUsersByUsername: return ParameterEncoding.URL
      case .CreateClip: return ParameterEncoding.JSON
      default: return nil
    }
  }

  var parameters: [String: AnyObject]? {
    switch self {
      case .PhoneAuthentication(let phoneNumber): return ["phone_number": phoneNumber]
      case .PhoneVerification(_, let phoneNumberVerificationCode): return ["phone_number_verification_code": phoneNumberVerificationCode]
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
        return userParameters
      case .FindUsersByPhoneNumbers(let phoneNumbers): return ["phone_number": ", ".join(phoneNumbers)]
      case .FindUsersByUsername(let username): return ["username": username]
      case .CreateClip(let videoData): return ["video": NSString(data: videoData, encoding: NSUTF8StringEncoding)!]
      default: return nil
    }
  }

  // MARK: URLRequestConvertible

  var URLRequest: NSURLRequest {
    let URL = NSURL(string: APIRoute.baseURLString)
      let mutableURLRequest = NSMutableURLRequest(URL: URL!.URLByAppendingPathComponent(path))
      mutableURLRequest.HTTPMethod = method.rawValue

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

protocol JSONPersistable: class {
  class func possibleJSONKeys() -> [String]
  class func objectFromJSONObject(JSON: JSONObject) -> Self?
}

extension Alamofire.Request {
  typealias ObjectCompletionHandler = (AnyObject?, NSError?) -> ()
  typealias ObjectsCompletionHandler = ([AnyObject]?, NSError?) -> ()

  func responseObject(completionHandler: ObjectCompletionHandler) -> Self {
    return responseJSON { (_, _, JSON, error) in
      self.handleResponse(JSON, error: error) { (objects, error) in
        completionHandler(objects?.first, error)
      }
    }
  }

  func responseObjects(completionHandler: ObjectsCompletionHandler) -> Self {
    return responseJSON { (_, _, JSON, error) in
      self.handleResponse(JSON, error: error, completionHandler: completionHandler)
    }
  }

  private func handleResponse(JSON: JSONData?, error: NSError?, completionHandler: ObjectsCompletionHandler) {
    if let error = error {
      completionHandler(nil, error)
    } else {
      if let JSONObject = JSON as JSONData? as? JSONObject {
        if let serverError = self.errorFromJSON(JSONObject) {
          completionHandler(nil, serverError)
        } else {
          // TODO: handle more than a user
          let objects = self.importFromJSON(User.self, JSON: JSONObject)
          completionHandler(objects, nil)
        }
      }
    }
  }

  // TODO: REMOVE
  func responsePersistable<T: JSONPersistable>(persistable: T.Type, completionHandler: API.CompletionHandler) -> Self {
    let serializer = responseSerializer { (JSON) in
      let objects = self.importFromJSON(persistable, JSON: JSON)
    }
    return response(serializer: serializer) { (_, _, _, error) in
      completionHandler(error)
    }
  }

  // TODO: REMOVE
  func responseAuthenticable(completionHandler: API.CompletionHandler) -> Self {
    let serializer = responseSerializer { (JSON) in
      if let authToken = JSON["auth_token"] as JSONData? as? String {
        APICredential.authToken = authToken
      }
    }
    return response(serializer: serializer) { (_, _, _, error) in
      completionHandler(error)
    }
  }

  // TODO: REMOVE
  func responseCurrentUser(completionHandler: API.CompletionHandler) -> Self {
    let serializer = responseSerializer { (JSON) in
      self.importFromJSON(User.self, JSON: JSON)
      if let user = JSON["user"] as JSONData? as? JSONObject {
        if let id = user["id"] as JSONData? as? String {
          User.currentUser = User.findByID(id)
        }
      }
    }
    return response(serializer: serializer) { (_, _, _, error) in
      completionHandler(error)
    }
  }

  // Helpers

  // TODO: REMOVE
  typealias AdditionHandler = (JSONObject) -> ()

  // TODO: REMOVE
  private func responseSerializer(addition: AdditionHandler?) -> Serializer {
    let serializer: Serializer = { (request, response, data) in
      let JSONSerializer = Request.JSONResponseSerializer()
      let (JSON: JSONData?, serializationError) = JSONSerializer(request, response, data)
      if let JSONObject = JSON as JSONData? as? JSONObject {
        if let serverError = self.errorFromJSON(JSONObject) {
          return (nil, serverError)
        }
        if let addition = addition {
          addition(JSONObject)
        }
        return (JSON, nil)
      }
      return (nil, serializationError)
    }
    return serializer
  }


  private func importFromJSON<T: JSONPersistable>(persistable: T.Type, JSON: JSONObject) -> [T] {
    var objects = [T]()
    for JSONKey in persistable.possibleJSONKeys() {
      if let JSONData: JSONData = JSON[JSONKey] as JSONData? {
        RLMRealm.defaultRealm().beginWriteTransaction()
        if let JSONObject = JSONData as? JSONObject {
          if let object = persistable.objectFromJSONObject(JSONObject) {
            objects.append(object)
          }
        } else if let JSONArray = JSONData as? JSONArray {
          for JSON in JSONArray {
            if let JSONObject = JSON as? JSONObject {
              if let object = persistable.objectFromJSONObject(JSONObject) {
                objects.append(object)
              }
            }
          }
        }
        RLMRealm.defaultRealm().commitWriteTransaction()
        break
      }
    }
    return objects
  }

  private func errorFromJSON(JSON: JSONObject) -> NSError? {
    if let error = JSON["error"] as JSONData? as? JSONObject {
      if let message = error["message"] as JSONData? as? String {
        return NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: 0, userInfo: [NSError.kSnowballAPIErrorMessage(): message])
      }
    }
    return nil
  }
}