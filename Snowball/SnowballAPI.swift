//
//  SnowballAPI.swift
//  Snowball
//
//  Created by James Martinez on 12/13/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation
import RealmSwift

struct SnowballAPI {

  // MARK: Internal

  static func request(route: SnowballRoute, completion: (response: Response) -> Void) {
    Alamofire.request(route).responseData { afResponse in
      switch afResponse.result {
      case .Success: completion(response: .Success)
      case .Failure(let error): completion(response: .Failure(error))
      }
    }
  }

  static func requestObject<T: Object>(route: SnowballRoute, completion: (response: ObjectResponse<T>) -> Void) {
    requestObject(route, beforeSave: nil, completion: completion)
  }

  static func requestObjects<T: Object>(route: SnowballRoute, completion: (response: ObjectResponse<[T]>) -> Void) {
    requestObjects(route, beforeSaveEveryObject: nil, completion: completion)
  }

  static func requestObject<T: Object>(route: SnowballRoute, beforeSave: ((object: T) -> Void)?, completion: (response: ObjectResponse<T>) -> Void) {
    Alamofire.request(route).responseJSON { afResponse in
      switch afResponse.result {
      case .Success(let value):
        if let value = value as? JSONObject {
          var object: T?
          Database.performTransaction {
            object = T.fromJSONObject(value, beforeSave: beforeSave)
          }
          if let object = object {
            completion(response: .Success(object))
          } else {
            completion(response: .Failure(NSError.snowballErrorWithReason(nil)))
          }
        } else {
          completion(response: .Failure(NSError.snowballErrorWithReason(nil)))
        }
      case .Failure(let error):
        completion(response: .Failure(error))
      }
    }
  }

  static func requestObjects<T: Object>(route: SnowballRoute, beforeSaveEveryObject: ((object: T) -> Void)?, completion: (response: ObjectResponse<[T]>) -> Void) {
    Alamofire.request(route).responseJSON { afResponse in
      switch afResponse.result {
      case .Success(let value):
        if let value = value as? JSONArray {
          var objects = [T]()
          Database.performTransaction {
            objects = T.fromJSONArray(value, beforeSaveEveryObject: beforeSaveEveryObject)
          }
          completion(response: .Success(objects))
        } else {
          completion(response: .Failure(NSError.snowballErrorWithReason(nil)))
        }
      case .Failure(let error):
        completion(response: .Failure(error))
      }
    }
  }

  static func queueClipForUploadingAndHandleStateChanges(clip: Clip, completion: (response: ObjectResponse<Clip>) -> Void) {
    guard let videoURLString = clip.videoURL, videoURL = NSURL(string: videoURLString) else { return }
    guard let thumbnailURLString = clip.thumbnailURL, thumbnailURL = NSURL(string: thumbnailURLString) else { return }

    Database.performTransaction {
      clip.state = .Uploading
      Database.save(clip)
    }

    let onFailure = {
      Database.performTransaction {
        clip.state = .UploadFailed
        Database.save(clip)
      }
      completion(response: .Failure(NSError.snowballErrorWithReason("Clip upload failed.")))
    }

    ClipUploadQueue.addOperationWithBlock {
      let multipartFormData: (MultipartFormData -> Void) = { multipartFormData in
        multipartFormData.appendBodyPart(fileURL: videoURL, name: "video")
        multipartFormData.appendBodyPart(fileURL: thumbnailURL, name: "thumbnail")
      }
      Alamofire.upload(SnowballRoute.UploadClip, multipartFormData: multipartFormData) { encodingResult in
        switch(encodingResult) {
        case .Success(let upload, _, _):
          upload.responseJSON { response in
            switch(response.result) {
            case .Success(let value):
              if let JSON = value as? JSONObject {
                Database.performTransaction {
                  clip.importJSON(JSON)
                  clip.state = .Default
                  Database.save(clip)
                }
              } else { onFailure() }
            case .Failure: onFailure()
            }
          }
        case .Failure: onFailure()
        }
      }
    }
  }

  // MARK: Private

  // This is unused but should probably be used in some form (maybe refactored first?)

//  private static func responseError(response: Alamofire.Response<AnyObject, NSError>) -> NSError {
//    var error = NSError.snowballErrorWithReason(nil)
//    if let data = response.data {
//      do {
//        if let serverErrorJSON = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject], let message = serverErrorJSON["message"] as? String {
//          error = NSError.snowballErrorWithReason(message)
//          return error
//        }
//      } catch {}
//    }
//    return error
//  }
}

// MARK: - Response
enum Response {
  case Success
  case Failure(NSError)
}

// MARK: - ObjectResponse
enum ObjectResponse<T> {
  case Success(T)
  case Failure(NSError)
}