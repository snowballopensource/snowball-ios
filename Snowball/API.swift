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

  struct AlamofireRequest {
    let method: Alamofire.Method
    let URLString: Alamofire.URLStringConvertible
    let parameters: [String: AnyObject]?

    init(_ method: Alamofire.Method, _ URLString: Alamofire.URLStringConvertible, parameters: [String: AnyObject]? = nil) {
      self.method = method
      self.URLString = URLString
      self.parameters = parameters
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

  // MARK: Helpers

  class func snowballURLString(path: String) -> String {
    return "http://private-78d57-snowballapi.apiary-mock.com/api/v1/" + path
  }

  class func performRequest(request: AlamofireRequest, importer: Importer, completionHandler: CompletionHandler?) {
    Alamofire.request(request.method, request.URLString, parameters: request.parameters).responseJSON { (request, response, JSON, error) in
      self.handleResponse(JSON: JSON, requestError: error, importer: importer, completionHandler: completionHandler)
    }
  }

  class func handleResponse(#JSON: AnyObject?, requestError: NSError?, importer: Importer, completionHandler: CompletionHandler?) {
    if let error = requestError {
      if let completion = completionHandler {
        completion(error)
      }
    } else {
      importer.importJSON(JSON, completionHandler: completionHandler)
    }
  }

  // MARK: -

  // MARK: Authentication

  class func signUp(#username: String, email: String, password: String, completionHandler: CompletionHandler?) {
    let parameters = ["user": ["username": username, "email": email, "password": password]]
    let request = AlamofireRequest(.POST, snowballURLString("users/sign_up"))
    let importer = Importer { (dict) in
      if let authToken = dict["auth_token"] as AnyObject? as? String {
        // TODO: do something with the auth token
        println(authToken)
      }
    }
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func signIn(#email: String, password: String, completionHandler: CompletionHandler?) {

  }

  // MARK: User

  class func getCurrentUser(completionHandler: CompletionHandler?) {
    let request = AlamofireRequest(.GET, snowballURLString("users/me"))
    let importer = Importer(type: User.self, JSONImportKey: "user")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func updateCurrentUser(completionHandler: CompletionHandler?) {

  }

  class func getCurrentUserFollowing(completionHandler: CompletionHandler?) {
    let request = AlamofireRequest(.GET, snowballURLString("users/me/following"))
    let importer = Importer(type: User.self, JSONImportKey: "users")
    performRequest(request, importer: importer, completionHandler: completionHandler)
  }

  class func followUser(user: User, completionHandler: CompletionHandler?) {

  }

  class func unfollowUser(user: User, completionHandler: CompletionHandler?) {

  }

  class func findUsersByPhoneNumbers(phoneNumbers: [String], completionHandler: CompletionHandler?) {

  }
  
  // MARK: Reel
  // MARK: Clip
}