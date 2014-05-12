//
//  SBReelViewController.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBClip.h"
#import "SBPlayerView.h"
#import "SBReelViewController.h"

@interface SBReelViewController ()

@property (weak, nonatomic) IBOutlet SBPlayerView *playerView;

@end

@implementation SBReelViewController

#pragma mark - UIViewController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [SBClip getClipsWithSuccess:^{
        // [self playReel];
    } failure:^(NSError *error) {
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self playReel];
}

#pragma mark - Video Player

- (void)playReel {
    NSMutableArray *playerItems = [NSMutableArray new];
    for (NSString *urlString in [self urlStrings]) {
        NSURL *videoURL = [NSURL URLWithString:urlString];
        AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:videoURL];
        [playerItems addObject:playerItem];
    }
    AVQueuePlayer *player = [[AVQueuePlayer alloc] initWithItems:[playerItems copy]];
    [self.playerView setPlayer:player];
    [player setActionAtItemEnd:AVPlayerActionAtItemEndAdvance];
    [player play];
}

- (NSArray *)urlStrings {
    return @[
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/c62269eed57a465985c3ebab822ae609",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/73593e859bc242259a797952508780d5",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/a1f3068935c44e9d9162779dd4b103b2",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/1830a36729f94bca91ed2bd0d6e24c77",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u2/984187c7812a4594a6d66b82dac2a336",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/c04d616bbfe24cc88c9f5694c45ed0c1",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/fce74f6d732a4e23818e8694d5b94a23",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/a8ce4e2b584e49b48e01339b3c5101e3",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/73bf345309824e7bafb3723d2c1b633c",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/7f3b21f0dac042849115248e50f72e38",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/1afaee4111334f05b55f2d8a196ed356",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/6c547bcd92a249adad7bbc559887a6dc",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u2/787c8bddca5a4e15bc518d98d0d8a6b1",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/e3a0ea0a36b844a18ab1760faa38e3c5",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/d50356a2f2e6404ca95be0fc1c442378",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/58c7738a09204cce906d1266582f2aa8",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/3d76324c94fa4b3a947f4b7e5f9acb8a",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u2/ff8330a9d3f34f608d580aa992856b2e",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u9/e5b38023f16a42bd8b26f80a0abcbd39",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/71f06e759f194e9da3d46b30bb2f4139",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/77aa291739394160b34dea11ad2e443b",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u2/4140bd598e1843a5b20ba8556d42122a",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/b64b6b13430e4445bcbc7f044244cd95",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/931023b8330c463e9b01f187e0136551",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/28b0027ee9bc403d8ef947dc16987b1f",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/8c75e65d84b444d98943559ac5341f90",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/d48a8557971a4ac480c01bdd341039a1",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/18cc74fe80ab485794cba3a126ea409d",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/16f38508fc61489694589b221ef9fff9",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/9f9d6cb41dca46fea9f56be1e7a57f3d",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/dbc4ba17779640eaa956fb0ee2f3eba4",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/9c0cecb2d3bb47f7a111fe02cf8d76bc",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/2854a268ae164fa0b078332b753bbbd2",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/7c96fcac854947a8a6cf0ceb5fcc82ee",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/186e543ad9884cea998aaf0bb2cb26aa",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/fcc1d73df8b94fb48a9be88e0c722a12",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/588fdb8e2fe045d8b33c1283fd00272c",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/21b946bf2ead41d39b3d1fe7ef5304b5",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u2/7e11c12b8f104f0db0d9dfd4e23a9919",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/da9819e1c3ca47178cb1d455c0667da6",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/69cbef4d757441249fb403a3f3583269",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/5fa6dbf60253459ca8bada42ec114ef4",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/7e447f118df14cd6abbafe8c480bd186",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u2/409703e2d9a544caaf97504e1c982b9a",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/3f75ae1150824a8b871d25cb87cb6a8d",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u3/1d00c82981d54f25b2d5b1ab0aa0c157",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u2/4d0668e262ca4dd89928553557cde86a",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/6489616774f949d6981844e93ff6ee73",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u2/81346270adb14072a07a4ed3df981956",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/84484ec5a31840b38e2a49d99512e979",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/b3048f1a44cf4394b511896b43d63b1e",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u2/145235858b7f4a5bbeb1f3209f876a37",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/85700296ed7545e98513e58a7b098ce4",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/3a293f4c6825482f971bc89bc05680fc",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/c4cbe22e6ddd4c69a5ea77370feed33d",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/be9e0d8f33884ca3a68d4f2d6ca9c45b",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/6b3351ca040e4902b99a35312febe072",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/66fc8d9331b048d6a5064849424e61c9",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/32ca7b318fde446ea48a3fb8268dafb0",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/94dc03e211f240c5bb6445e967b4ec09",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/1ad13eb3393844b68e3162b4f76ecfa5",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/68a96576ba7f45168e679d105000d8f4",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/0ddc3158ab674ce8b1ca36ab2184b4a3",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u30/fee112d9fa0b4d179ec7f7776409e25b",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/04f86f52ca9b40f4b31f5f3dbb3a33c7",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u2/55635587cfc242ce9eff3261c8345466",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/caa4c461a54a4c25ac17b457d732f78c",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/537d2c70682b4fd4ab306ddc52f1acfc",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u3/e3d6a461808f4ba980967f4f93eee9cd",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/ece38b3ecddb4331b1dc34c865c210e2",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/20a47311fef54eb98df7f127782f56dc",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u1/09b473fc584440648aef5ea2307347e8",
             @"http://d38paydxy3kfwm.cloudfront.net/67F8EA99-62C7-48A3-9E7A-18D503221C35/u19/9e2790d420c043228b80c85c3f753570",
             ];
}

@end
