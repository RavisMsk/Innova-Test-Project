//
//  ITUserManager.m
//  InnovaTest
//
//  Created by Nikita Anisimov on 11/07/14.
//  Copyright (c) 2014 Nikita Anisimov. All rights reserved.
//

#import "ITUserManager.h"

@interface ITUserManager ()

@property (nonatomic, strong, readwrite) ITSUser *user;
@property (nonatomic, readwrite) ITUserManagerState state;

@end

@implementation ITUserManager

static ITUserManager *_sharedManager=nil;

+ (instancetype)sharedManager{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager=[[ITUserManager alloc] init];
    });
    return _sharedManager;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.state = ITUserManagerFetching;
    [self fetchCurrentUser];
  }
  return self;
}

- (void)fetchCurrentUser{
  //  Query for self
  PFQuery *selfQuery = [PFQuery queryWithClassName:@"ITSUser"];
  [selfQuery whereKey:@"UDID"
              equalTo:IT_DEV_ID];
  [selfQuery findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error){
    if (error){
      NSLog(@"Error quering current user: %@", error);
    }else{
      if (objs.count == 1){
        //        Found ourselves
        self.user = objs[0];
        self.state = ITUserManagerReady;
      }else if (objs.count == 0){
        //        Create ourselves
        self.user = [ITSUser object];
        self.user.UDID = IT_DEV_ID;
        self.user.lastOnline = [NSDate dateWithTimeIntervalSince1970:0];
        [self.user saveInBackgroundWithBlock:^(BOOL succeded, NSError *error){
          if (succeded) {
            self.state = ITUserManagerReady;
          }
        }];
      }else{
        //        Seems like bugz
        NSAssert(false, @"Oops, seems like duplicate: %@", objs);
      }
    }
  }];
}

@end
