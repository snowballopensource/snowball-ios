//
//  ClipSpec.swift
//  Snowball
//
//  Created by James Martinez on 7/28/15.
//  Copyright (c) 2015 Snowball, Inc. All rights reserved.
//

// TODO: Remove the comments once Swift 2.0 comes out and importing files to be tested is much easier. :)

//import Nimble
//import Quick
//import Snowball
//
//class ClipSpec: QuickSpec {}
//
//// MARK: - Equatable
//extension ClipSpec {
//  override func spec() {
//    describe("==") {
//      it("returns true when the clips' IDs are equal") {
//        let clipOne = Clip(id: "1")
//        let clipTwo = Clip(id: "1")
//        expect(clipOne).to(equal(clipTwo))
//      }
//      it("returns false when the clips' IDs are not equal") {
//        let clipOne = Clip(id: "1")
//        let clipTwo = Clip(id: "2")
//        expect(clipOne).toNot(equal(clipTwo))
//      }
//      it("returns false when one of the clip's IDs are nil") {
//        let clipOne = Clip(id: "1")
//        let clipTwo = Clip(id: nil)
//        expect(clipOne).toNot(equal(clipTwo))
//      }
//      it("returns false when both of the clip's IDs are nil") {
//        let clipOne = Clip(id: nil)
//        let clipTwo = Clip(id: nil)
//        expect(clipOne).toNot(equal(clipTwo))
//      }
//    }
//  }
//}