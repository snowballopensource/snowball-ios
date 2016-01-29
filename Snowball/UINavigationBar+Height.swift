//
//  UINavigationBar+Height.swift
//  Snowball
//
//  Created by James Martinez on 1/28/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
  public override func sizeThatFits(size: CGSize) -> CGSize {
    let width = superview?.frame.size.width ?? 0
    return CGSize(width: width, height: 60)
  }
}