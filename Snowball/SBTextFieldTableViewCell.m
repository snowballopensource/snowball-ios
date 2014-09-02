//
//  SBTextFieldTableViewCell.m
//  Snowball
//
//  Created by James Martinez on 9/2/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBTextFieldTableViewCell.h"

@interface SBTextFieldTableViewCell ()

@end

@implementation SBTextFieldTableViewCell

- (IBAction)dismissKeyboard:(id)sender {
    [self.textField resignFirstResponder];
}

@end
