//
//  SnowballAPI.swift
//  Snowball
//
//  Created by James Martinez on 10/24/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

struct SnowballAPI {
  typealias Route = Router

  static func request(route: Route, completion: (response: Response) -> Void) {
    Alamofire.request(route).validate().response { request, response, data, error in
      if error == nil {
        completion(response: Response.Success)
      } else if let data = data {
        completion(response: Response.Failure(errorFromAlamofireData(data)))
      } else {
        completion(response: Response.Failure(NSError.snowballErrorWithReason("Server Error")))
      }
    }
  }

  static func requestObject<T: JSONImportable>(route: Route, completion: (response: ObjectResponse<T>) -> Void) {
    Alamofire.request(route).validate().responseJSON { afResponse in
      switch afResponse.result {
      case .Success(let value):
        if let object = value as? JSONObject {
          completion(response: ObjectResponse.Success(T.fromJSONObject(object)))
        } else {
          completion(response: ObjectResponse.Failure(NSError.snowballErrorWithReason("Error importing object.")))
        }
        break
      case .Failure:
        completion(response: ObjectResponse.Failure(errorFromAlamofireResponse(afResponse)))
        break
      }
    }
  }

  static func requestObjects<T: JSONImportable>(route: Route, completion: (response: ObjectResponse<[T]>) -> Void) {
    Alamofire.request(route).validate().responseJSON { afResponse in
      switch afResponse.result {
      case .Success(let value):
        if let array = value as? JSONArray {
          completion(response: ObjectResponse.Success(T.fromJSONArray(array)))
        } else {
          completion(response: ObjectResponse.Failure(NSError.snowballErrorWithReason("Error importing objects.")))
        }
        break
      case .Failure:
        completion(response: ObjectResponse.Failure(errorFromAlamofireResponse(afResponse)))
        break
      }
    }
  }

  private static func errorFromAlamofireResponse(response: Alamofire.Response<AnyObject, NSError>) -> NSError {
    if let data = response.data {
      return errorFromAlamofireData(data)
    } else {
      return NSError.snowballErrorWithReason("Request Error")
    }
  }

  private static func errorFromAlamofireData(data: NSData) -> NSError {
    var error = NSError.snowballErrorWithReason("Unknown Error")
    do {
      if let serverErrorJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject], let message = serverErrorJSON["message"] as? String {
        error = NSError.snowballErrorWithReason(message)
      }
    } catch {}
    return error
  }
}

enum Response {
  case Success
  case Failure(NSError)
}

enum ObjectResponse<T> {
  case Success(T)
  case Failure(NSError)
}