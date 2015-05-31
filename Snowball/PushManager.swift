//
//  PushManager.swift
//  Snowball
//
//  Created by James Martinez on 5/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import UIKit

/*

** Because you're awesome, this is the command for sending a push via cURL.
** Get the device registration token from the logs and the api key from Googs.

curl --header "Authorization: key=${API_KEY}" \
--header Content-Type:"application/json" \
https://gcm-http.googleapis.com/gcm/send \
-d "{\"to\":\"${THIS_DEVICE_REGISTRATION_TOKEN}\",\"notification\":{\"body\":\"Hello\"}}"

*/

class PushManager: NSObject, GGLInstanceIDDelegate {

  private class var sharedPushManager: PushManager {
    struct Singleton {
      static let sharedPushManager = PushManager()
    }
    return Singleton.sharedPushManager
  }

  private let gcmSenderID = "471712850615"
  private var deviceToken: NSData?

  // MARK: - Internal

  class func registerForPushNotifications() {
    let types = UIUserNotificationType.Alert | UIUserNotificationType.Sound
    let settings = UIUserNotificationSettings(forTypes: types, categories: nil)
    let application = UIApplication.sharedApplication()
    application.registerUserNotificationSettings(settings)
    application.registerForRemoteNotifications()
  }

  class func registrationSucceeded(#deviceToken: NSData) {
    let config = GGLInstanceIDConfig.defaultConfig()
    config.delegate = sharedPushManager
    GGLInstanceID.sharedInstance().startWithConfig(config)
    sharedPushManager.deviceToken = deviceToken
    sharedPushManager.onTokenRefresh()
  }

  class func registrationFailed(#error: NSError) {
    error.print("Push notification registration")
  }

  class func handleRemoteNotification(#userInfo: [NSObject: AnyObject]) {
    println("Push notification received: \(userInfo)")

    if let aps = userInfo["aps"] as? [String: AnyObject] {
      if let message = aps["alert"] as? String {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: UIAlertControllerStyle.Alert)
        let okAction = UIAlertAction(title: NSLocalizedString("OK"), style: UIAlertActionStyle.Default, handler: nil)
        alert.addAction(okAction)
        if let rootVC = UIApplication.sharedApplication().delegate?.window??.rootViewController {
          rootVC.presentViewController(alert, animated: true, completion: nil)
        }
      }
    }
  }

  // MARK: - GGLInstanceIDDelegate

  func onTokenRefresh() {
    if let deviceToken = deviceToken {
      let registrationOptions = [
        kGGLInstanceIDRegisterAPNSOption: deviceToken,
        kGGLInstanceIDAPNSServerTypeSandboxOption: true
      ]
      GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID, scope: kGGLInstanceIDScopeGCM, options: registrationOptions) { (token, error) -> Void in
        if let error = error {
          error.print("GCM push registration reponse")
        } else {
          println("Registered notification token: \(token)")
        }
      }
    } else {
      println("The shared push notification manager does not have a device token set.")
    }
  }
}