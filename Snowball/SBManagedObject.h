//
//  SBManagedObject.h
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface SBManagedObject : NSManagedObject

+ (NSString *)entityName;

- (void)create;
- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure;
- (void)update;
- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure;

- (void)save;
- (void)delete;

@end
