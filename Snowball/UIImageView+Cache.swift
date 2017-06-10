//
//  UIImageView+Cache.swift
//  Snowball
//
//  Created by James Martinez on 12/31/15.
//  Copyright © 2015 Snowball, Inc. All rights reserved.
//

import Foundation
import Haneke

extension UIImageView {
  func setImageFromURL(_ URL: NSURL) {
    hnk_cancelSetImage()
    hnk_setImageFromURL(URL, placeholder: nil, format: Format<UIImage>(name: "original"), failure: nil, success: nil)
  }
}
