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

  static func request(_ route: SnowballRoute, completion: @escaping (_ response: Response) -> Void) {
    Alamofire.request(route).validate().responseJSON { afResponse in
      switch afResponse.result {
      case .Success: completion(response: .Success)
      case .Failure: completion(response: .Failure(errorFromResponse(afResponse)))
      }
    }
  }

  static func requestObject<T: Object>(_ route: SnowballRoute, completion: @escaping (_ response: ObjectResponse<T>) -> Void) {
    requestObject(route, beforeSave: nil, completion: completion)
  }

  static func requestObjects<T: Object>(_ route: SnowballRoute, completion: @escaping (_ response: ObjectResponse<[T]>) -> Void) {
    requestObjects(route, beforeSaveEveryObject: nil, completion: completion)
  }

  static func requestObject<T: Object>(_ route: SnowballRoute, beforeSave: ((_ object: T) -> Void)?, completion: @escaping (_ response: ObjectResponse<T>) -> Void) {
    Alamofire.request(route).validate().responseJSON { afResponse in
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
      case .Failure:
        completion(response: .Failure(errorFromResponse(afResponse)))
      }
    }
  }

  static func requestObjects<T: Object>(_ route: SnowballRoute, beforeSaveEveryObject: ((_ object: T) -> Void)?, completion: @escaping (_ response: ObjectResponse<[T]>) -> Void) {
    Alamofire.request(route).validate().responseJSON { afResponse in
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
      case .Failure:
        completion(response: .Failure(errorFromResponse(afResponse)))
      }
    }
  }

  static func queueClipForUploadingAndHandleStateChanges(_ clip: Clip, completion: @escaping (_ response: ObjectResponse<Clip>) -> Void) {
    guard let videoURLString = clip.videoURL, let videoURL = URL(string: videoURLString) else { return }

    Database.performTransaction {
      clip.state = .Uploading
      Database.save(clip)
    }

    let onFailure: (_ response: Alamofire.Response<AnyObject, NSError>?) -> Void = { response in
      Database.performTransaction {
        clip.state = .UploadFailed
        Database.save(clip)
      }
      if let response = response {
        completion(response: .Failure(errorFromResponse(response)))
      } else {
        completion(response: .Failure(NSError.snowballErrorWithReason(nil)))
      }
    }

    ClipUploadQueue.addOperationWithBlock {
      let multipartFormData: ((MultipartFormData) -> Void) = { multipartFormData in
        multipartFormData.appendBodyPart(fileURL: videoURL, name: "video")
      }
      Alamofire.upload(SnowballRoute.UploadClip, multipartFormData: multipartFormData) { encodingResult in
        switch(encodingResult) {
        case .Success(let upload, _, _):
          upload.validate().responseJSON { afResponse in
            switch(afResponse.result) {
            case .Success(let value):
              if let JSON = value as? JSONObject {
                Analytics.track("Create Clip")
                Database.performTransaction {
                  clip.importJSON(JSON)
                  clip.state = .Default
                  Database.save(clip)
                }
              } else { onFailure(response: afResponse) }
            case .Failure: onFailure(response: afResponse)
            }
          }
        case .Failure: onFailure(response: nil)
        }
      }
    }
  }

  static func uploadUserAvatar(_ image: UIImage, completion: @escaping (_ response: ObjectResponse<User>) -> Void) {
    let onFailure: (_ response: Alamofire.Response<AnyObject, NSError>?) -> Void = { response in
      if let response = response {
        completion(response: .Failure(errorFromResponse(response)))
      } else {
        completion(response: .Failure(NSError.snowballErrorWithReason(nil)))
      }
    }
    let multipartFormData: ((MultipartFormData) -> Void) = { multipartFormData in
      if let data = UIImageJPEGRepresentation(image, 1) {
        multipartFormData.appendBodyPart(data: data, name: "avatar", fileName: "image.jpg", mimeType: "image/jpeg")
      } else {
        onFailure(response: nil)
        return
      }
    }
    Alamofire.upload(SnowballRoute.UploadCurrentUserAvatar, multipartFormData: multipartFormData) { encodingResult in
      switch encodingResult {
      case .Success(let upload, _, _):
        upload.validate().responseJSON { afResponse in
          switch afResponse.result {
          case .Success(let value):
            if let JSON = value as? JSONObject, let user = User.currentUser {
              Database.performTransaction {
                user.importJSON(JSON)
                Database.save(user)
              }
              completion(response: .Success(user))
            } else { onFailure(response: afResponse) }
          case .Failure: onFailure(response: afResponse)
          }
        }
      case .Failure: onFailure(response: nil)
      }
    }
  }

  // MARK: Private

  fileprivate static func errorFromResponse(_ response: Alamofire.Response<AnyObject, NSError>) -> NSError {
    var error = NSError.snowballErrorWithReason(nil)
    if let data = response.data {
      do {
        if let serverErrorJSON = try JSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject], let message = serverErrorJSON["message"] as? String {
          error = NSError.snowballErrorWithReason(message)
          return error
        }
      } catch {}
    }
    return error
  }
}

// MARK: - Response
enum Response {
  case success
  case failure(NSError)
}

// MARK: - ObjectResponse
enum ObjectResponse<T> {
  case success(T)
  case failure(NSError)
}
