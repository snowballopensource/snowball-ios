//
//  SnowballAPI.swift
//  Snowball
//
//  Created by James Martinez on 10/21/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

struct SnowballAPI {

  // TODO: Rename Router to SnowballRoute once the API migration has been completed
  static func requestObjects<T: JSONImportable>(route: Router, completion: (result: SnowballAPIResult<[T]>) -> Void) {
    request(route).responseJSON { (request, response, result) in
      switch(result) {
      case .Success(let value):
        var objects = [T]()
        if let JSON = value as? JSONArray {
          objects = T.objectsFromJSONArray(JSON)
        }
        completion(result: SnowballAPIResult.Success(objects))
      case .Failure(_, let error):
        completion(result: SnowballAPIResult.Failure(error as NSError))
      }
    }
  }

  private static func request(route: Router) -> Alamofire.Request {
    return Alamofire.request(route).validate()
  }
}

enum SnowballAPIResult<Value> {
  case Success(Value)
  case Failure(NSError)
}
