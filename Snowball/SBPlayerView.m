//
//  SBPlayerView.m
//  Snowball
//
//  Created by James Martinez on 5/12/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBPlayerView.h"

@implementation SBPlayerView

+ (Class)layerClass {
    return [AVPlayerLayer class];
}

- (AVQueuePlayer *)player {
    AVPlayerLayer *playerLayer = (AVPlayerLayer *)self.layer;
    return (AVQueuePlayer *)playerLayer.player;
}

- (void)setPlayer:(AVPlayer *)player {
    [(AVPlayerLayer *)self.layer setPlayer:player];
}

@end
