//
//  SnowballAPI.swift
//  Snowball
//
//  Created by James Martinez on 8/8/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

struct SnowballAPI {
  static func request(route: SnowballAPIRoute) -> Request {
    return Alamofire.request(route).validate()
  }
}

// MARK: - SnowballAPIRoute
enum SnowballAPIRoute: URLRequestConvertible {
  private static let baseURL = NSURL(string: "https://api.snowball.is/v1")!

  case Ping
  // Clips
  case ClipStream(page: Int)

  var method: Alamofire.Method {
    switch self {
    default: return .GET
    }
  }

  var path: String {
    switch self {
    case .Ping: return "/"
    case .ClipStream: return "/clips/stream"
    }
  }

  var parameterEncoding: ParameterEncoding {
    switch self {
    default: return ParameterEncoding.URL
    }
  }

  var parameters: [String: AnyObject]? {
    switch self {
    case .ClipStream(let page): return ["page": page]
    default: return nil
    }
  }

  var URLRequest: NSMutableURLRequest {
    let URLRequest = NSMutableURLRequest(URL: SnowballAPIRoute.baseURL.URLByAppendingPathComponent(path))
    URLRequest.HTTPMethod = method.rawValue

    let kAuthTokenKey = "CurrentUserAuthToken"
    if let token = NSUserDefaults.standardUserDefaults().valueForKey(kAuthTokenKey) {
      URLRequest.setValue("Token token=\(token)", forHTTPHeaderField: "Authorization")
    }

    return parameterEncoding.encode(URLRequest, parameters: parameters).0
  }
}

// MARK: - JSONRepresentable
typealias JSONObject = [String: AnyObject]
typealias JSONArray = [JSONObject]

protocol JSONRepresentable {
  init?(json: JSONObject)
  static func fromJSONArray(jsonArray: JSONArray) -> [Self]
  func asJSON() -> JSONObject
}

extension JSONRepresentable {
  static func fromJSONArray(jsonArray: JSONArray) -> [Self] {
    var collection = [Self]()
    for jsonObject in jsonArray {
      if let object = Self(json: jsonObject) {
        collection.append(object)
      }
    }
    return collection
  }
}

// MARK: - Request
extension Request {
  func responseObject<T: JSONRepresentable>(completionHandler: Response<T, NSError> -> Void) -> Self {
    let responseSerializer = ResponseSerializer<T, NSError> { request, response, data, error in
      guard error == nil else { return .Failure(error!) }

      let JSONResponseSerializer = Request.JSONResponseSerializer()
      let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

      switch result {
      case .Success(let value):
        if
          let value = value as? JSONObject,
          let responseObject = T(json: value) {
          return .Success(responseObject)
        } else {
          return .Failure(NSError(domain: "", code: 0, userInfo: nil))
        }
      case .Failure(let error): return .Failure(error)
      }
    }
    return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
  }

  func responseCollection<T: JSONRepresentable>(completionHandler: Response<[T], NSError> -> Void) -> Self {
    let responseSerializer = ResponseSerializer<[T], NSError> { request, response, data, error in
      guard error == nil else { return .Failure(error!) }

      let JSONResponseSerializer = Request.JSONResponseSerializer()
      let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

      switch result {
      case .Success(let value):
        if let value = value as? JSONArray {
          let responseCollection = T.fromJSONArray(value)
          return .Success(responseCollection)
        } else {
          return .Failure(NSError(domain: "", code: 0, userInfo: nil))
        }
      case .Failure(let error): return .Failure(error)
      }
    }
    return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
  }
}