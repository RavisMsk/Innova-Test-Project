//
//  ITUser.m
//  InnovaTest
//
//  Created by Nikita Anisimov on 11/07/14.
//  Copyright (c) 2014 Nikita Anisimov. All rights reserved.
//

#import "ITUser.h"

typedef void (^ITUserBlock)(ITUser *me);

@interface ITUser ()

@property (strong) NSString *UDID;
@property (strong) NSDate *lastOnline;

//Async Singleton
+ (void)currentUserWithHandler:(ITUserBlock)h;
//Inheritance
+ (NSString *)parseClassName;

@end

@implementation ITUser

@dynamic UDID, lastOnline;

#pragma mark - Private

#pragma mark Singleton

static ITUser *_currentUser=nil;

+ (void)currentUserWithHandler:(ITUserBlock)h{
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
//      Get the existing object
    PFQuery *selfQuery = [PFQuery queryWithClassName:@"ITUser"];
    [selfQuery whereKey:@"UDID"
                equalTo:IT_DEV_ID];
    [selfQuery findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error){
      if (error){
        NSLog(@"Error quering current user: %@", error);
      }else{
        if (objs.count == 1){
          _currentUser = objs[0];
          if (h)
            h(_currentUser);
        }else if (objs.count == 0){
          _currentUser = [ITUser object];
          _currentUser.UDID = IT_DEV_ID;
          _currentUser.lastOnline = [NSDate dateWithTimeIntervalSince1970:0];
          [_currentUser saveInBackgroundWithBlock:^(BOOL succeded, NSError *error){
            if (succeded){
              if (h)
                h(_currentUser);
            }else{
              NSAssert(false, @"Couldnt save new user: %@", error);
            }
          }];
        }else{
          NSAssert(false, @"Oops, seems like duplicate: %@", objs);
        }
      }
    }];
  });
  if (h && _currentUser)
    h(_currentUser);
  else
    h(nil);
}

#pragma mark Inheritance overloads

+ (NSString *)parseClassName{
  return @"ITUser";
}

#pragma mark - Public

+ (void)setOnlineState:(BOOL)onLine{
  [self currentUserWithHandler:^(ITUser *me){
    if (me!=nil){
      me.lastOnline = onLine?[NSDate date]:[NSDate dateWithTimeIntervalSince1970:0];
      [me saveInBackground];
    }
  }];
}

+ (void)onlineTimeLeft:(ITUserTimeLeftBlock)h{
  [self currentUserWithHandler:^(ITUser *me){
    if (h){
      NSDate *now = [NSDate date];
      NSInteger timeLeft = IT_ONLINE_TIME - [now timeIntervalSinceDate:me.lastOnline];
      h( timeLeft <= 0 ? 0 : timeLeft );
    }
  }];
}

@end
