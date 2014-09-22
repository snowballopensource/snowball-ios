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
    let type: RLMObject.Type
    let JSONImportKey: String
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
    if let completion = completionHandler {
      if let error = requestError {
        completion(error)
      } else {
        if let dict = JSON as? [String: AnyObject] {
          if let objectDict = dict[importer.JSONImportKey] as AnyObject? as? [String: AnyObject] {
            Realm.saveInBackground({ (realm) in
              importer.type.importFromDictionary(objectDict, inRealm: realm)
              return
              }, completionHandler: {
                completion(nil)
            })
          } else if let objectArray = dict[importer.JSONImportKey] as AnyObject? as? [AnyObject] {
            // TODO: import the array
          }
        }
      }
    }
  }

  // MARK: -

  // MARK: Authentication

  class func signUp(#username: String, email: String, password: String, completionHandler: CompletionHandler?) {

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