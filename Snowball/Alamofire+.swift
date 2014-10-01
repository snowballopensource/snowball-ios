//
//  Alamofire+.swift
//  Snowball
//
//  Created by James Martinez on 9/30/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation

// https://github.com/Alamofire/Alamofire#generic-response-object-serialization

protocol JSONObjectSerializable: class {
  class func objectFromJSON(JSON: [String: AnyObject]) -> AnyObject
  class func objectsFromJSON(JSON: [String: AnyObject]) -> [AnyObject]
}

extension Alamofire.Request {
  func responseObject<T: JSONObjectSerializable>(completionHandler: (T?, NSError?) -> Void) -> Self {
    let serializer: Serializer = { (request, response, data) in
      let JSONSerializer = Request.JSONResponseSerializer()
      let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
      if response != nil && JSON != nil {
        RLMRealm.defaultRealm().beginWriteTransaction()
        let object = T.objectFromJSON(JSON as [String: AnyObject]) as RLMObject
        RLMRealm.defaultRealm().commitWriteTransaction()
        return (object, nil)
      }
      return (nil, serializationError)
    }
    return response(serializer: serializer) { (request, response, object, error) in
      completionHandler(object as? T, error)
    }
  }

  func responseObjects<T: JSONObjectSerializable>(completionHandler: ([T]?, NSError?) -> Void) -> Self {
    let serializer: Serializer = { (request, response, data) in
      let JSONSerializer = Request.JSONResponseSerializer()
      let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
      if response != nil && JSON != nil {
        RLMRealm.defaultRealm().beginWriteTransaction()
        let objects = T.objectsFromJSON(JSON as [String: AnyObject])
        RLMRealm.defaultRealm().commitWriteTransaction()
        return (objects, nil)
      }
      return (nil, serializationError)
    }
    return response(serializer: serializer) { (request, response, objects, error) in
      completionHandler(objects as? [T], error)
    }
  }
}