//
//  UINavigationBar+Transparent.swift
//  Snowball
//
//  Created by James Martinez on 1/28/16.
//  Copyright © 2016 Snowball, Inc. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {

  // MARK: Properties

  private struct AssociatedKeys {
    static var transparentKey = "transparentKey"
  }

  var transparent: Bool {
    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.transparentKey) as? Bool ?? false
    }
    set {
      objc_setAssociatedObject(self, &AssociatedKeys.transparentKey, newValue, objc_AssociationPolicy.OBJC_ASSOCIATION_RETAIN_NONATOMIC)
      if newValue {
        setBackgroundImage(UIImage(), for: .default)
        isTranslucent = true
        shadowImage = UIImage()
      } else {
        let appearance = UINavigationBar.appearance()
        setBackgroundImage(appearance.backgroundImage(for: .default), for: .default)
        isTranslucent = appearance.isTranslucent
        shadowImage = appearance.shadowImage
      }
    }
  }
}
