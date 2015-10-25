//
//  API.swift
//  Snowball
//
//  Created by James Martinez on 12/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import AFNetworking
import Alamofire
import Foundation
import UIKit

struct API {
  static func request(URLRequest: URLRequestConvertible) -> Alamofire.Request {
    return Alamofire.request(URLRequest).validate(statusCode: 200..<300)
  }

  // MARK - Internal

  static func uploadClip(clip: Clip, completion: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> ()) {
    ClipUploadQueue.sharedQueue.addTask {
      let requestURL = NSURL(string: Router.baseURLString)!.URLByAppendingPathComponent("clips")
      let request = AFHTTPRequestSerializer().multipartFormRequestWithMethod("POST",
        URLString: requestURL.absoluteString,
        parameters: nil,
        constructingBodyWithBlock: { (formData: AFMultipartFormData!) in
          do { try formData.appendPartWithFileURL(NSURL(string: clip.videoURL!)!, name: "video") } catch {}
          do { try formData.appendPartWithFileURL(NSURL(string: clip.thumbnailURL!)!, name: "thumbnail") } catch {}
          return
        }, error: nil)
      let encodedAuthTokenData = "\(APICredential.authToken!):".dataUsingEncoding(NSUTF8StringEncoding)!
      let encodedAuthToken = encodedAuthTokenData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
      request.setValue("Basic \(encodedAuthToken)", forHTTPHeaderField: "Authorization")

      self.tryUpload(request, completion: completion)
    }
  }

  static func changeAvatarToImage(image: UIImage, completion: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> ()) {
    ClipUploadQueue.sharedQueue.addTask {
      let requestURL = NSURL(string: Router.baseURLString)!.URLByAppendingPathComponent("users/me")
      let request = AFHTTPRequestSerializer().multipartFormRequestWithMethod("PATCH",
        URLString: requestURL.absoluteString,
        parameters: nil,
        constructingBodyWithBlock: { (formData: AFMultipartFormData!) in
          formData.appendPartWithFileData(UIImagePNGRepresentation(image)!, name: "avatar", fileName: "image.png", mimeType: "image/png")
          return
        }, error: nil)
      let encodedAuthTokenData = "\(APICredential.authToken!):".dataUsingEncoding(NSUTF8StringEncoding)!
      let encodedAuthToken = encodedAuthTokenData.base64EncodedStringWithOptions(NSDataBase64EncodingOptions(rawValue: 0))
      request.setValue("Basic \(encodedAuthToken)", forHTTPHeaderField: "Authorization")

      self.tryUpload(request, completion: completion)
    }
  }

  // MARK: - Private

  private static func tryUpload(request: NSURLRequest, completion: (NSURLRequest, NSHTTPURLResponse?, AnyObject?, NSError?) -> ()) {
    let manager = AFURLSessionManager(sessionConfiguration: NSURLSessionConfiguration.defaultSessionConfiguration())
    let uploadTask = manager.uploadTaskWithStreamedRequest(request, progress: nil) { (response, responseObject, error) in
      completion(request, response as? NSHTTPURLResponse, responseObject, error)
    }
    uploadTask.resume()
  }
}