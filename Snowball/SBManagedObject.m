//
//  SBManagedObject.m
//  Snowball
//
//  Created by James Martinez on 5/7/14.
//  Copyright (c) 2014 Snowball, Inc. All rights reserved.
//

#import "SBManagedObject.h"

@implementation SBManagedObject

+ (NSString *)entityName {
    // This should be subclassed by the mogenerator generated classes
    REQUIRE_SUBCLASS
    return nil;
}

#pragma mark - Remote

- (void)create {
	[self createWithSuccess:nil failure:nil];
}

- (void)createWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    REQUIRE_SUBCLASS
}

- (void)update {
	[self updateWithSuccess:nil failure:nil];
}

- (void)updateWithSuccess:(void(^)(void))success failure:(void(^)(NSError *error))failure {
    REQUIRE_SUBCLASS
}

#pragma mark - Manipulation

- (void)save {
    [self.managedObjectContext MR_saveToPersistentStoreAndWait];
}

- (void)delete {
    [self MR_deleteEntity];
}

@end
