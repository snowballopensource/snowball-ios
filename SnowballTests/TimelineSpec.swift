//
//  TimelineSpec.swift
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
//class TimelineSpec: QuickSpec {
//  override func spec() {
//    let clips = [Clip(id: "1"), Clip(id: "2")]
//    let timeline = Timeline()
//    timeline.clips = clips
//
//    describe("#clipAfterClip") {
//      it("returns the next clip") {
//        expect(timeline.clipAfterClip(clips.first!)).to(equal(clips.last!))
//      }
//      it("returns nil when there is no next clip") {
//        expect(timeline.clipAfterClip(clips.last!)).to(beNil())
//      }
//    }
//
//    describe("#clipBeforeClip") {
//      it("returns the previous clip") {
//        expect(timeline.clipBeforeClip(clips.last!)).to(equal(clips.first!))
//      }
//      it("returns nil when there is no previous clip") {
//        expect(timeline.clipBeforeClip(clips.first!)).to(beNil())
//      }
//    }
//  }
//}