//
//  SnowballAPI.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

struct SnowballAPI {

  // MARK: Internal

  static func requestObjects<T: ActiveModel>(route: SnowballRoute, completion: (response: ObjectResponse<[T]>) -> Void) {
    Alamofire.request(route).responseJSON { afResponse in
      switch afResponse.result {
      case .Success(let value):
        if let value = value as? JSONArray {
          completion(response: ObjectResponse.Success(T.fromJSONArray(value)))
        } else {
          completion(response: .Failure(NSError.snowballErrorWithReason(nil)))
        }
      case .Failure(let error):
        completion(response: .Failure(error))
      }
    }
  }

  // MARK: Private

  private static func responseError(response: Alamofire.Response<AnyObject, NSError>) -> NSError {
    var error = NSError.snowballErrorWithReason(nil)
    if let data = response.data {
      do {
        if let serverErrorJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject], let message = serverErrorJSON["message"] as? String {
          error = NSError.snowballErrorWithReason(message)
          return error
        }
      } catch {}
    }
    return error
  }
}

// MARK: - ObjectResponse
enum ObjectResponse<T> {
  case Success(T)
  case Failure(NSError)
}