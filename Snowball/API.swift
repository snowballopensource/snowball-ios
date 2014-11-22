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
  // Snowball API error into an NSError and importing any changed auth
  // tokens.

  static func request(URLRequest: URLRequestConvertible) -> Alamofire.Request {
    return Alamofire.request(URLRequest).validate(statusCode: 200..<300)
  }

  // Since Alamofire doesn't have multipart uploads yet, AFNetworking was
  // brought back in to handle it.
  static func uploadClip(fileURL: NSURL) {
    let manager = AFHTTPRequestOperationManager()
    manager.requestSerializer.setAuthorizationHeaderFieldWithUsername(APICredential.authToken, password: "")
    let URL = APIRoute.baseURLString.stringByAppendingPathComponent("clips")
    manager.POST(URL, parameters: nil, constructingBodyWithBlock: { (formData) in
        formData.appendPartWithFileURL(fileURL, name: "video", error: nil)
        return
      }, success: { (_, responseObject) in
        Importer.mapResponseJSONToPersistable(persistable: Clip.self, JSON: responseObject, error: nil) { (object, error) in
          println(object)
          println(error)
        }
        return
      }, failure: { (operation, error) in
        Importer.mapResponseJSONToPersistable(persistable: Clip.self, JSON: operation.responseObject, error: error) { (object, error) in
          println(object)
          println(error)
        }
        return
    })
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
  case SignUp(username: String, email: String, password: String)
  case SignIn(username: String, password: String)
  case PhoneAuthentication(phoneNumber: String)
  case PhoneVerification(userID: String, phoneNumberVerificationCode: String)
  // User
  case GetCurrentUser
  case UpdateCurrentUser(name: String?, username: String?, email: String?, phoneNumber: String?)
  case GetCurrentUserFollowing
  case FollowUser(userID: String)
  case UnfollowUser(userID: String)
  case FindUsersByPhoneNumbers(phoneNumbers: [String])
  case FindUsersByUsername(username: String)
  // Clip
  case GetClipStream
  case DeleteClip(clipID: String)
  case FlagClip(clipID: String)

  var method: Alamofire.Method {
    switch self {
      case .SignUp: return .POST
      case .SignIn: return .POST
      case .PhoneAuthentication: return .POST
      case .PhoneVerification: return .POST
      case .GetCurrentUser: return .GET
      case .UpdateCurrentUser: return .PATCH
      case .GetCurrentUserFollowing: return .GET
      case .FollowUser: return .POST
      case .UnfollowUser: return .DELETE
      case .FindUsersByPhoneNumbers: return .GET
      case .FindUsersByUsername: return .GET
      case .GetClipStream: return .GET
      case .DeleteClip: return .DELETE
      case .FlagClip: return .POST
    }
  }

  var path: String {
    switch self {
      case .SignUp: return "users/sign-up"
      case .SignIn: return "users/sign-in"
      case .PhoneAuthentication: return "users/phone-auth"
      case .PhoneVerification(let userID, _): return "users/\(userID)/phone-verification"
      case .GetCurrentUser: return "users/me"
      case .UpdateCurrentUser: return "users/me"
      case .GetCurrentUserFollowing: return "users/me/following"
      case .FollowUser(let userID): return "users/\(userID)/follow"
      case .UnfollowUser(let userID): return "users/\(userID)/follow"
      case .FindUsersByPhoneNumbers: return "users"
      case .FindUsersByUsername: return "users"
      case .GetClipStream: return "clips/stream"
      case .DeleteClip(let clipID): return "clips/\(clipID)"
      case .FlagClip(let clipID): return "clips/\(clipID)"
    }
  }

  var parameterEncoding: ParameterEncoding? {
    switch self {
      case .SignUp: return ParameterEncoding.JSON
      case .SignIn: return ParameterEncoding.JSON
      case .PhoneAuthentication: return ParameterEncoding.JSON
      case .PhoneVerification: return ParameterEncoding.JSON
      case .UpdateCurrentUser: return ParameterEncoding.JSON
      case .FindUsersByPhoneNumbers: return ParameterEncoding.URL
      case .FindUsersByUsername: return ParameterEncoding.URL
      default: return nil
    }
  }

  var parameters: [String: AnyObject]? {
    switch self {
      case .SignUp(let username, let email, let password): return ["username": username, "email": email, "password": password]
      case .SignIn(let username, let password): return ["username": username, "password": password]
      case .PhoneAuthentication(let phoneNumber): return ["phone_number": phoneNumber]
      case .PhoneVerification(_, let phoneNumberVerificationCode): return ["phone_number_verification_code": phoneNumberVerificationCode]
      case .UpdateCurrentUser(let name, let username, let email, let phoneNumber):
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
        if let newPhoneNumber = phoneNumber {
          userParameters["phone_number"] = newPhoneNumber
        }
        return userParameters
      case .FindUsersByPhoneNumbers(let phoneNumbers): return ["phone_number": ", ".join(phoneNumbers)]
      case .FindUsersByUsername(let username): return ["username": username]
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
      if let params = parameters {
        return parameterEncoding!.encode(mutableURLRequest, parameters: params).0
      }
      return mutableURLRequest
  }
}

protocol JSONPersistable: class {
  class func objectFromJSONObject(JSON: JSONObject) -> Self?
}

extension Alamofire.Request {
  typealias CompletionHandler = (AnyObject?, NSError?) -> ()

  func responseNoContent(completionHandler: (NSError?) -> ()) -> Self {
    return response { (_, _, _, error) in
      completionHandler(error)
    }
  }

  func responsePersistable<T: JSONPersistable>(persistable: T.Type, completionHandler: CompletionHandler) -> Self {
    return responseJSON { (request, response, JSON, error) in
      Importer.mapResponseJSONToPersistable(persistable: persistable, JSON: JSON, error: error) { (object, error) in
        completionHandler(object, error)
      }
    }
  }
}

struct Importer {
  static func mapResponseJSONToPersistable<T: JSONPersistable>(#persistable: T.Type, JSON: JSONData?, error: NSError?, completionHandler: Alamofire.Request.CompletionHandler) {
    if let error = error {
      if let JSONData: JSONData = JSON {
        if let serverError = self.errorFromJSON(JSONData) {
          completionHandler(nil, serverError)
        } else {
          completionHandler(nil, error)
        }
      } else {
        completionHandler(nil, error)
      }
    } else if let JSONData: JSONData = JSON {
      if let JSONObject = JSONData as? JSONObject {
        if let userID = JSONObject["id"] as? String {
          User.currentUserID = userID
        }
        if let authToken = JSONObject["auth_token"] as? String {
          APICredential.authToken = authToken
        }
      }
      let object = self.importJSONToPersistable(persistable: persistable, JSON: JSONData)
      completionHandler(object, nil)
    }
  }

  private static func importJSONToPersistable<T: JSONPersistable>(#persistable: T.Type, JSON: JSONData) -> [T] {
    var objects = [T]()
    RLMRealm.defaultRealm().beginWriteTransaction()
    if let JSONObject = JSON as? JSONObject {
      if let object = persistable.objectFromJSONObject(JSONObject) {
        objects.append(object)
      }
    } else if let JSONArray = JSON as? JSONArray {
      for JSON in JSONArray {
        if let JSONObject = JSON as? JSONObject {
          if let object = persistable.objectFromJSONObject(JSONObject) {
            objects.append(object)
          }
        }
      }
    }
    RLMRealm.defaultRealm().commitWriteTransaction()
    return objects
  }

  private static func errorFromJSON(JSON: JSONData) -> NSError? {
    if let JSONObject = JSON as? JSONObject {
      if let message = JSONObject["message"] as JSONData? as? String {
        return NSError(domain: NSBundle.mainBundle().bundleIdentifier!, code: 0, userInfo: [NSError.kSnowballAPIErrorMessage(): message])
      }
    }
    return nil
  }
}