//
//  SBUserImageView.h
//  Snowball
//
//  Created by James Martinez on 6/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SBUser;

@interface SBUserImageView : UIImageView

- (void)setImageWithUser:(SBUser *)user;

@end
