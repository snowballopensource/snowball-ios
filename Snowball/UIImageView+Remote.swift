//
//  UIImageView+Remote.swift
//  Snowball
//
//  Created by James Martinez on 8/10/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import AlamofireImage
import Foundation

extension UIImageView {
  func setImageFromRemoteURL(URL: NSURL?, placeholderImage: UIImage = UIImage()) {
    if let URL = URL {
      af_setImageWithURL(URL, placeholderImage: placeholderImage)
    } else {
      image = placeholderImage
    }
  }
}
