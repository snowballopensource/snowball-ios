//
//  UIImageView+.swift
//  Snowball
//
//  Created by James Martinez on 9/23/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation
import Haneke

extension UIImageView {
  typealias CompletionHandler = (NSError?) -> ()

  func setImageFromURL(URL: NSURL, placeholder: UIImage? = nil, completionHandler: CompletionHandler? = nil) {
    let cache = Haneke.sharedDataCache
    cache.fetch(URL: URL).onSuccess { (data) in
      self.image = UIImage(data: data)
      if let completion = completionHandler { completion(nil) }
      }.onFailure { (error) in
        if let completion = completionHandler { completion(error) }
    }
  }
}