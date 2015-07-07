//
//  API.swift
//  Snowball
//
//  Created by James Martinez on 12/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Alamofire
import Foundation
import UIKit

struct API {
  static func request(URLRequest: URLRequestConvertible) -> Alamofire.Request {
    return Alamofire.request(URLRequest).validate(statusCode: 200..<300)
  }

  // MARK - Internal

  static func uploadClip(clip: Clip, completion: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> ()) {
    UploadQueue.sharedQueue.addTask {
      let requestURL = NSURL(string: Router.baseURLString)!.URLByAppendingPathComponent("clips")
      let request = AFHTTPRequestSerializer().multipartFormRequestWithMethod("POST",
        URLString: requestURL.absoluteString!,
        parameters: nil,
        constructingBodyWithBlock: { (formData: AFMultipartFormData!) in
          formData.appendPartWithFileURL(clip.videoURL, name: "video", error: nil)
          formData.appendPartWithFileURL(clip.thumbnailURL, name: "thumbnail", error: nil)
          return
        }, error: nil)
      let encodedAuthTokenData = "\(APICredential.authToken!):".dataUsingEncoding(NSUTF8StringEncoding)!
      let encodedAuthToken = encodedAuthTokenData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
      request.setValue("Basic \(encodedAuthToken)", forHTTPHeaderField: "Authorization")

      self.tryUpload(request, retryCount: 3, completion: completion)
    }
  }

  static func changeAvatarToImage(image: UIImage, completion: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> ()) {
    UploadQueue.sharedQueue.addTask {
      let requestURL = NSURL(string: Router.baseURLString)!.URLByAppendingPathComponent("users/me")
      let request = AFHTTPRequestSerializer().multipartFormRequestWithMethod("PATCH",
        URLString: requestURL.absoluteString!,
        parameters: nil,
        constructingBodyWithBlock: { (formData: AFMultipartFormData!) in
          formData.appendPartWithFileData(UIImagePNGRepresentation(image), name: "avatar", fileName: "image.png", mimeType: "image/png")
          return
        }, error: nil)
      let encodedAuthTokenData = "\(APICredential.authToken!):".dataUsingEncoding(NSUTF8StringEncoding)!
      let encodedAuthToken = encodedAuthTokenData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
      request.setValue("Basic \(encodedAuthToken)", forHTTPHeaderField: "Authorization")

      self.tryUpload(request, retryCount: 3, completion: completion)    }
  }

  // MARK: - Private

  private static func tryUpload(request: NSURLRequest, retryCount: Int, completion: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> ()) {
    let manager = AFURLSessionManager(sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
    let uploadTask = manager.uploadTaskWithStreamedRequest(request, progress: nil) { (response, responseObject, error) in
      if error != nil && retryCount > 1 {
        self.tryUpload(request, retryCount: retryCount - 1, completion: completion)
      }
      completion(request, response as! NSHTTPURLResponse?, responseObject, error)
    }
    uploadTask.resume()
  }
}

// MARK: - Global

func displayAPIErrorToUser(errorJSON: AnyObject?) {
  if let errorJSON: AnyObject = errorJSON {
    if let message = errorJSON["message"] as? String {
      let alertController = UIAlertController(title: NSLocalizedString("Error", comment: ""), message: message, preferredStyle: UIAlertControllerStyle.Alert)
      alertController.addAction(UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: UIAlertActionStyle.Cancel, handler: nil))
      if let rootVC = AppDelegate.sharedDelegate.window!.rootViewController {
        rootVC.presentViewController(alertController, animated: true, completion: nil)
      }
    }
  }
}
