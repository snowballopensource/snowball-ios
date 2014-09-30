//
//  String+.swift
//  Snowball
//
//  Created by James Martinez on 9/29/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

import Foundation

extension String {
  func encodedAsBase64() -> String {
    let encodedData = dataUsingEncoding(NSUTF8StringEncoding)
    return encodedData!.base64EncodedStringWithOptions(NSDataBase64EncodingOptions.fromRaw(0)!)
  }
}