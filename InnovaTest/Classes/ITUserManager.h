//
//  ITUserManager.h
//  InnovaTest
//
//  Created by Nikita Anisimov on 11/07/14.
//  Copyright (c) 2014 Nikita Anisimov. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "ITSUser.h"

typedef enum{
  ITUserManagerFetching,
  ITUserManagerReady
} ITUserManagerState;

@interface ITUserManager : NSObject

@property (nonatomic, strong, readonly) ITSUser *user;
@property (nonatomic, readonly) ITUserManagerState state;

+ (instancetype)sharedManager;

@end
