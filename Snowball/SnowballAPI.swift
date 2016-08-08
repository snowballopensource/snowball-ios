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

enum SnowballAPIRoute: URLRequestConvertible {
  private static let baseURL = NSURL(string: "https://api.snowball.is/v1")!

  case Ping
  // Clips
  case ClipStream

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

protocol ResponseObjectSerializable {
  init?(response: NSHTTPURLResponse, representation: AnyObject)
}

protocol ResponseCollectionSerializable {
  static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Self]
}

extension ResponseCollectionSerializable where Self: ResponseObjectSerializable {
  static func collection(response response: NSHTTPURLResponse, representation: AnyObject) -> [Self] {
    var collection = [Self]()
    if let collectionRepresentation = representation as? [[String: AnyObject]] {
      for objectRepresentation in collectionRepresentation {
        if let object = Self(response: response, representation: objectRepresentation) {
          collection.append(object)
        }
      }
    }
    return collection
  }
}

extension Request {
  func responseObject<T: ResponseObjectSerializable>(completionHandler: Response<T, NSError> -> Void) -> Self {
    let responseSerializer = ResponseSerializer<T, NSError> { request, response, data, error in
      guard error == nil else { return .Failure(error!) }

      let JSONResponseSerializer = Request.JSONResponseSerializer()
      let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

      switch result {
      case .Success(let value):
        if let response = response, responseObject = T(response: response, representation: value) {
          return .Success(responseObject)
        } else {
          return .Failure(NSError(domain: "", code: 0, userInfo: nil))
        }
      case .Failure(let error): return .Failure(error)
      }
    }
    return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
  }

  func responseCollection<T: ResponseCollectionSerializable>(completionHandler: Response<[T], NSError> -> Void) -> Self {
    let responseSerializer = ResponseSerializer<[T], NSError> { request, response, data, error in
      guard error == nil else { return .Failure(error!) }

      let JSONResponseSerializer = Request.JSONResponseSerializer()
      let result = JSONResponseSerializer.serializeResponse(request, response, data, error)

      switch result {
      case .Success(let value):
        if let response = response {
          let responseObject = T.collection(response: response, representation: value)
          return .Success(responseObject)
        } else {
          return .Failure(NSError(domain: "", code: 0, userInfo: nil))
        }
      case .Failure(let error): return .Failure(error)
      }
    }
    return response(responseSerializer: responseSerializer, completionHandler: completionHandler)
  }
}