//
//  SBWebViewController.m
//  Snowball
//
//  Created by James Martinez on 6/3/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBWebViewController.h"

@interface SBWebViewController ()

@property (nonatomic, weak) IBOutlet UIWebView *webView;

@end

@implementation SBWebViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    NSURLRequest *request = [NSURLRequest requestWithURL:self.url];
    [self.webView loadRequest:request];
}

@end
