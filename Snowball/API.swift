//
//  API.swift
//  Snowball
//
//  Created by James Martinez on 9/30/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

struct API {
  typealias CompletionHandler = (NSError?) -> ()

  func request(route: APIRouter, completionHandler: CompletionHandler?) {
    Alamofire.request(route).responseJSON { (request, response, JSON, error) in
      APIImporter.importJSONFromRoute(route, JSON: JSON as [String: AnyObject]) { (error) in
        if let completion = completionHandler {
          completion(error)
        }
      }
    }
  }
}