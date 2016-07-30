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
    Alamofire.request(route).validate().responseJSON { afResponse in
      switch afResponse.result {
      case .Success: completion(response: .Success)
        // TODO: Handle errors correctly. This is skipped right now because we're sending a 201 with no body when
        // a clip is liked, but a 5XX with an error when there is an error, along with JSON.
        // Unfortunately I can't handle both JSON and no JSON here, so for the time being error handling is disabled.
      case .Failure: completion(response: .Success)//.Failure(errorFromResponse(afResponse)))
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

  static func requestObjects<T: Object>(route: SnowballRoute, beforeSaveEveryObject: ((object: T) -> Void)?, completion: (response: ObjectResponse<[T]>) -> Void) {
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

  static func queueClipForUploadingAndHandleStateChanges(clip: Clip, completion: (response: ObjectResponse<Clip>) -> Void) {
    guard let videoURLString = clip.videoURL, videoURL = NSURL(string: videoURLString) else { return }

    Database.performTransaction {
      clip.state = .Uploading
      Database.save(clip)
    }

    let onFailure: (response: Alamofire.Response<AnyObject, NSError>?) -> Void = { response in
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
      let multipartFormData: (MultipartFormData -> Void) = { multipartFormData in
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

  static func uploadUserAvatar(image: UIImage, completion: (response: ObjectResponse<User>) -> Void) {
    let onFailure: (response: Alamofire.Response<AnyObject, NSError>?) -> Void = { response in
      if let response = response {
        completion(response: .Failure(errorFromResponse(response)))
      } else {
        completion(response: .Failure(NSError.snowballErrorWithReason(nil)))
      }
    }
    let multipartFormData: (MultipartFormData -> Void) = { multipartFormData in
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

  private static func errorFromResponse(response: Alamofire.Response<AnyObject, NSError>) -> NSError {
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