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
      case .success: completion(.success)
      case .failure: completion(.failure(errorFromResponse(afResponse)))
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
      case .success(let value):
        if let value = value as? JSONObject {
          var object: T?
          Database.performTransaction {
            object = T.fromJSONObject(value, beforeSave: beforeSave)
          }
          if let object = object {
            completion(.success(object))
          } else {
            completion(.failure(NSError.snowballErrorWithReason(nil)))
          }
        } else {
          completion(.failure(NSError.snowballErrorWithReason(nil)))
        }
      case .failure:
        completion(.failure(errorFromResponse(afResponse)))
      }
    }
  }

  static func requestObjects<T: Object>(_ route: SnowballRoute, beforeSaveEveryObject: ((_ object: T) -> Void)?, completion: @escaping (_ response: ObjectResponse<[T]>) -> Void) {
    Alamofire.request(route).validate().responseJSON { afResponse in
      switch afResponse.result {
      case .success(let value):
        if let value = value as? JSONArray {
          var objects = [T]()
          Database.performTransaction {
            objects = T.fromJSONArray(value, beforeSaveEveryObject: beforeSaveEveryObject)
          }
          completion(.success(objects))
        } else {
          completion(.failure(NSError.snowballErrorWithReason(nil)))
        }
      case .failure:
        completion(.failure(errorFromResponse(afResponse)))
      }
    }
  }

  static func queueClipForUploadingAndHandleStateChanges(_ clip: Clip, completion: @escaping (_ response: ObjectResponse<Clip>) -> Void) {
    guard let videoURLString = clip.videoURL, let videoURL = URL(string: videoURLString) else { return }

    Database.performTransaction {
      clip.state = .Uploading
      Database.save(clip)
    }

    let onFailure: (_ response: Alamofire.DataResponse<Any>?) -> Void = { response in
      Database.performTransaction {
        clip.state = .UploadFailed
        Database.save(clip)
      }
      if let response = response {
        completion(.failure(errorFromResponse(response)))
      } else {
        completion(.failure(NSError.snowballErrorWithReason(nil)))
      }
    }

    ClipUploadQueue.addOperationWithBlock {
      let multipartFormData: ((MultipartFormData) -> Void) = { multipartFormData in
        multipartFormData.append(videoURL, withName: "video")
      }
      Alamofire.upload(multipartFormData: multipartFormData, with: SnowballRoute.uploadCurrentUserAvatar) { encodingResult in
        switch(encodingResult) {
        case .success(let upload, _, _):
          upload.validate().responseJSON { afResponse in
            switch(afResponse.result) {
            case .success(let value):
              if let JSON = value as? JSONObject {
                Analytics.track("Create Clip")
                Database.performTransaction {
                  clip.importJSON(JSON)
                  clip.state = .Default
                  Database.save(clip)
                }
              } else { onFailure(afResponse) }
            case .failure: onFailure(afResponse)
            }
          }
        case .failure: onFailure(nil)
        }
      }
    }
  }

  static func uploadUserAvatar(_ image: UIImage, completion: @escaping (_ response: ObjectResponse<User>) -> Void) {
    let onFailure: (_ response: Alamofire.DataResponse<Any>?) -> Void = { response in
      if let response = response {
        completion(.failure(errorFromResponse(response)))
      } else {
        completion(.failure(NSError.snowballErrorWithReason(nil)))
      }
    }
    let multipartFormData: ((MultipartFormData) -> Void) = { multipartFormData in
      if let data = UIImageJPEGRepresentation(image, 1) {
        multipartFormData.append(data, withName: "avatar", fileName: "image.jpg", mimeType: "image/jpeg")
      } else {
        onFailure(nil)
        return
      }
    }
    Alamofire.upload(multipartFormData: multipartFormData, with: SnowballRoute.uploadCurrentUserAvatar) { encodingResult in
      switch encodingResult {
      case .success(let upload, _, _):
        upload.validate().responseJSON { afResponse in
          switch afResponse.result {
          case .success(let value):
            if let JSON = value as? JSONObject, let user = User.currentUser {
              Database.performTransaction {
                user.importJSON(JSON)
                Database.save(user)
              }
              completion(.success(user))
            } else { onFailure(afResponse) }
          case .failure: onFailure(afResponse)
          }
        }
      case .failure: onFailure(nil)
      }
    }
  }

  // MARK: Private

  fileprivate static func errorFromResponse(_ response: Alamofire.DataResponse<Any>) -> NSError {
    var error = NSError.snowballErrorWithReason(nil)
    if let data = response.data {
      do {
        if let serverErrorJSON = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: AnyObject], let message = serverErrorJSON["message"] as? String {
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
