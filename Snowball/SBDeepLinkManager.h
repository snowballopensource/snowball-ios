//
//  SBDeepLinkManager.h
//  Snowball
//
//  Created by James Martinez on 7/25/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SBDeepLinkManager : NSObject

+ (BOOL)handleDeepLinkURL:(NSURL *)url;

@end
