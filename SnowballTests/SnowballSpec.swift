//
//  SnowballSpec.swift
//  Snowball
//
//  Created by James Martinez on 7/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

import Nimble
import Quick
import Snowball

class SnowballSpec: QuickSpec {
  override func spec() {
    describe("Snowball") {
      it("is awesome") {
        expect(true).to(beTruthy())
      }
    }
  }
}