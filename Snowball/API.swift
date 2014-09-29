//
//  API.swift
//  Snowball
//
//  Created by James Martinez on 9/18/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

class API {
  typealias CompletionHandler = (NSError?) -> ()

  struct Credential {
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
    static var base64EncodedString: String? {
      get {
        var encodedString = ""
        if let token = authToken {
          let credentialData = "\(token):".dataUsingEncoding(NSUTF8StringEncoding)
          encodedString = credentialData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!)
        }
        return encodedString
      }
    }
  }

  struct Request {
    let method: Alamofire.Method
    let URLString: Alamofire.URLStringConvertible
    let parameters: [String: AnyObject]?

    init(_ method: Alamofire.Method, _ URLString: Alamofire.URLStringConvertible, parameters: [String: AnyObject]? = nil) {
      self.method = method
      self.URLString = URLString
      self.parameters = parameters
      prepareAuthorizationHeader()
    }

    private func prepareAuthorizationHeader() {
      var defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders ?? [:]
      var authorizationHeaderValue: String?
      if let base64EncodedCredential = Credential.base64EncodedString {
        authorizationHeaderValue = "Basic \(base64EncodedCredential)"
      }
      defaultHeaders["Authorization"] = authorizationHeaderValue
      Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders = defaultHeaders
    }
  }

  struct Importer {
    let type: RLMObject.Type?
    let JSONImportKey: String?
    typealias ManualImportHandler = ([String: AnyObject]) -> ()
    let manualImportHandler: ManualImportHandler?

    init(type: RLMObject.Type, JSONImportKey: String) {
      self.type = type
      self.JSONImportKey = JSONImportKey
    }

    init(manualImportHandler: ManualImportHandler) {
      self.manualImportHandler = manualImportHandler
    }

    func importJSON(JSON: AnyObject?, completionHandler: CompletionHandler?) {
      if let dict = JSON as? [String: AnyObject] {
        if let manualImportHandler = manualImportHandler {
          manualImportHandler(dict)
          if let completion = completionHandler { completion(nil) }
        } else {
          if let importKey = JSONImportKey {
            if let importType = type {
              if let objectDict = dict[importKey] as AnyObject? as? [String: AnyObject] {
                Realm.saveInBackground({ (realm) in
                  importType.importFromDictionary(objectDict, inRealm: realm)
                  return
                  }, completionHandler: {
                    if let completion = completionHandler { completion(nil) }
                })
              } else if let objectArray = dict[importKey] as AnyObject? as? [AnyObject] {
                Realm.saveInBackground({ (realm) in
                  importType.importFromArray(objectArray, inRealm: realm)
                  return
                  }, completionHandler: {
                    if let completion = completionHandler { completion(nil) }
                })
              }
            }
          }
        }
      }
    }
  }

  // MARK: -

  // MARK: Helpers

  class func snowballURLString(path: String) -> String {
    // return "http://private-78d57-snowballapi.apiary-mock.com/api/v1/" + path
    return "http://snowball-staging.herokuapp.com/api/v1/" + path
  }

  class func performRequest(request: Request, importer: Importer, completionHandler: CompletionHandler? = nil) {
    var parameterEncoding = Alamofire.ParameterEncoding.JSON
    if (request.method == Alamofire.Method.GET) {
      parameterEncoding = Alamofire.ParameterEncoding.URL
    }
    Alamofire
      .request(request.method, request.URLString, parameters: request.parameters, encoding: parameterEncoding)
      .responseJSON { (request, response, JSON, error) in
        self.handleResponse(response, JSON: JSON, error: error, importer: importer, completionHandler: completionHandler)
    }
  }

  class func handleResponse(response: NSHTTPURLResponse?, JSON: AnyObject?, error: NSError?, importer: Importer, completionHandler: CompletionHandler? = nil) {
    if response?.statusCode == 401 {
      User.currentUser = nil
      if let completion = completionHandler {
        completion(error)
      }
    } else if let error = error {
      if let completion = completionHandler {
        completion(error)
      }
    } else {
      importer.importJSON(JSON, completionHandler: completionHandler)
    }
  }

  // MARK: -

  // MARK: Authentication

  class func signUp(#username: String, email: String, password: String, completionHandler: CompletionHandler? = nil) {
    let parameters = ["user": ["username": username, "email": email, "password": password]]
    let request = Request(.POST, snowballURLString("users/sign_up"), parameters: parameters)
    let importer = Importer { (dict) in
      Credential.authToken = dict["auth_token"] as AnyObject? as String?
    }
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func signIn(#email: String, password: String, completionHandler: CompletionHandler? = nil) {
    let parameters = ["user": ["email": email, "password": password]]
    let request = Request(.POST, snowballURLString("users/sign_in"), parameters: parameters)
    let importer = Importer { (dict) in
      Credential.authToken = dict["auth_token"] as AnyObject? as String?
    }
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  // MARK: User

  class func getCurrentUser(completionHandler: CompletionHandler? = nil) {
    let request = Request(.GET, snowballURLString("users/me"))
    let importer = Importer(type: User.self, JSONImportKey: "user")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func updateCurrentUser(username: String? = nil, email: String? = nil, name: String? = nil, completionHandler: CompletionHandler? = nil) {
    var changes = [String: String]()
    if let newUsername = username {
      changes["username"] = newUsername
    }
    if let newEmail = email {
      changes["email"] = newEmail
    }
    if let newName = name {
      changes["name"] = newName
    }
    let parameters = ["user": changes]
    let request = Request(.PATCH, snowballURLString("users/me"), parameters: parameters)
    let importer = Importer(type: User.self, JSONImportKey: "user")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func getCurrentUserFollowing(completionHandler: CompletionHandler? = nil) {
    let request = Request(.GET, snowballURLString("users/me/following"))
    let importer = Importer(type: User.self, JSONImportKey: "users")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func followUserID(userID: String, completionHandler: CompletionHandler? = nil) {
    let request = Request(.POST, snowballURLString("users/\(userID)/follow"))
    let importer = Importer(type: User.self, JSONImportKey: "user")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func unfollowUserID(userID: String, completionHandler: CompletionHandler? = nil) {
    let request = Request(.DELETE, snowballURLString("users/\(userID)/follow"))
    let importer = Importer(type: User.self, JSONImportKey: "user")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func findUsersByPhoneNumbers(phoneNumbers: [String], completionHandler: CompletionHandler? = nil) {
    var contacts = [AnyObject]()
    for phoneNumber in phoneNumbers {
      contacts.append(["phone_number": phoneNumber])
    }
    let parameters = ["contacts": contacts]
    let request = Request(.POST, snowballURLString("users/find_by_contacts"), parameters: parameters)
    let importer = Importer(type: User.self, JSONImportKey: "user")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }
  
  // MARK: Reel

  class func getReelStream(completionHandler: CompletionHandler? = nil) {
    let request = Request(.GET, snowballURLString("reels/stream"))
    let importer = Importer(type: Reel.self, JSONImportKey: "reels")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func createReel(title: String? = nil, participantIDs: [String]? = nil, completionHandler: CompletionHandler? = nil) {
    var reelParameters = [String: AnyObject]()
    if let newTitle = title {
      reelParameters["title"] = newTitle
    }
    if let newParticipantIDs = participantIDs {
      reelParameters["participant_ids"] = newParticipantIDs
    }
    let parameters = ["reel": reelParameters]
    let request = Request(.POST, snowballURLString("reels"), parameters: parameters)
    let importer = Importer(type: Reel.self, JSONImportKey: "reel")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func updateReel(#reelID: String, title: String, completionHandler: CompletionHandler? = nil) {
    var reelParameters = [String: AnyObject]()
    reelParameters["title"] = title
    let parameters = ["reel": reelParameters]
    let request = Request(.PATCH, snowballURLString("reels/\(reelID)"), parameters: parameters)
    let importer = Importer(type: Reel.self, JSONImportKey: "reel")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func getReelParticipants(#reelID: String, completionHandler: CompletionHandler? = nil) {
    let request = Request(.GET, snowballURLString("reels/\(reelID)/participants"))
    let importer = Importer(type: User.self, JSONImportKey: "users")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func addParticipantToReel(#reelID: String, userID: String, completionHandler: CompletionHandler? = nil) {
    let request = Request(.POST, snowballURLString("reels/\(reelID)/participants/\(userID)"))
    let importer = Importer(type: User.self, JSONImportKey: "user")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func removeCurrentUserAsParticipantInReel(#reelID: String, completionHandler: CompletionHandler? = nil) {
    let request = Request(.DELETE, snowballURLString("reels/\(reelID)/participants/me"))
    let importer = Importer(type: User.self, JSONImportKey: "user")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  // MARK: Clip

  class func getUnwatchedClipsInReel(#reelID: String, since: NSDate?, completionHandler: CompletionHandler? = nil) {
    var parameters = [String: AnyObject]()
    if let sinceDate = since {
      parameters["since"] = Int(sinceDate.timeIntervalSince1970)
    }
    let request = Request(.GET, snowballURLString("reels/\(reelID)/clips"), parameters: parameters)
    let importer = Importer(type: Clip.self, JSONImportKey: "clips")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func createClip(#reelID: String, videoData: NSData, completionHandler: CompletionHandler? = nil) {
    let clipParameters = ["video": NSString(data:videoData, encoding:NSUTF8StringEncoding)]
    let parameters = ["clip": clipParameters]
    let request = Request(.POST, snowballURLString("reels/\(reelID)/clips"), parameters: parameters)
    let importer = Importer(type: Clip.self, JSONImportKey: "clip")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }
}