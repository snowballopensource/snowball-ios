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
}

func displayAPIErrorToUser(errorJSON: AnyObject?) {
  if let errorJSON: AnyObject = errorJSON {
    if let message = errorJSON["message"] as? String {
      let alertController = UIAlertController(title: NSLocalizedString("Error"), message: message, preferredStyle: UIAlertControllerStyle.Alert)
      alertController.addAction(UIAlertAction(title: NSLocalizedString("OK"), style: UIAlertActionStyle.Cancel, handler: nil))
      if let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController {
        rootVC.presentViewController(alertController, animated: true, completion: nil)
      }
    }
  }
}
