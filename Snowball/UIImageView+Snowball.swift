//
//  UIImageView+Snowball.swift
//  Snowball
//
//  Created by James Martinez on 8/13/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Haneke
import Photos
import UIKit

extension UIImageView {
  func setImageFromURL(url: NSURL) {
    if url.scheme == "http" {
      hnk_setImageFromURL(url, format: Format<UIImage>(name: "original"))
    } else if url.scheme == "assets-library" {
      let result = PHAsset.fetchAssetsWithALAssetURLs([url], options: PHFetchOptions())
      if let asset = result.firstObject as? PHAsset {
        let manager = PHImageManager.defaultManager()
        let size = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        manager.requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFill, options: PHImageRequestOptions(), resultHandler: { (image, info) -> Void in
          if let image = image {
            self.hnk_setImage(image, animated: false, success: nil)
          }
        })
      }
    } else {
      let imageData = NSData(contentsOfURL: url)!
      let image = UIImage(data: imageData)
      if let image = image {
        hnk_setImage(image, animated: false, success: nil)
      }
    }
  }
}
