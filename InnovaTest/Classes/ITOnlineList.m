//
//  ITOnlineList.m
//  InnovaTest
//
//  Created by Nikita Anisimov on 11/07/14.
//  Copyright (c) 2014 Nikita Anisimov. All rights reserved.
//

#import "ITOnlineList.h"

#import "ITSUser.h"
#import "ITUserManager.h"

@interface ITOnlineList ()

@property (nonatomic, strong) NSTimer *fetchTimer;

- (void)refreshList;

@end

@implementation ITOnlineList

#pragma mark - Private

- (void)refreshList{
  ITSUser *user = [[ITUserManager sharedManager] user];
  if ([user isOnline]){
    PFQuery *q = [ITSUser query];
    NSDate *minDateForOnline = [NSDate dateWithTimeIntervalSinceNow: -IT_ONLINE_TIME ];
    [q whereKey:@"lastOnline"
    greaterThan:minDateForOnline];
    [q findObjectsInBackgroundWithBlock:^(NSArray *objs, NSError *error){
      if (error){
        NSLog(@"Error fetching online users: %@", error);
      }else{
        self.onlineUsers = nil;
        self.onlineUsers = objs;
        if (self.target)
          [self.target reloadData];
      }
    }];
  }else{
    ITSUser *placeholderUser = [ITSUser object];
    placeholderUser.UDID = @"Вы сейчас вне сети...";
    placeholderUser.lastOnline = nil;
    self.onlineUsers = @[ placeholderUser ];
    if (self.target)
      [self.target reloadData];
  }
}

#pragma mark - Lifecycle

- (instancetype)init
{
  self = [super init];
  if (self) {
    self.fetchTimer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                       target:self
                                                     selector:@selector(refreshList)
                                                     userInfo:nil
                                                      repeats:YES];
    self.onlineUsers = [NSArray array];
    self.target = nil;
  }
  return self;
}

#pragma mark - Singleton

static ITOnlineList *_sharedList=nil;

+ (instancetype)sharedList{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedList = [[ITOnlineList alloc] init];
    });
    return _sharedList;
}

@end
