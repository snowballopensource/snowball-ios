//
//  SBUserImageView.h
//  Snowball
//
//  Created by James Martinez on 6/9/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SBUserImageView : UIImageView

+ (UIImage *)placeholderImageWithInitials:(NSString *)initials withSize:(CGSize)size;

@end
