//
//  ITSUser.m
//  InnovaTest
//
//  Created by Nikita Anisimov on 11/07/14.
//  Copyright (c) 2014 Nikita Anisimov. All rights reserved.
//

#import "ITSUser.h"

@implementation ITSUser

@dynamic UDID, lastOnline;

+ (NSString *)parseClassName{
  return @"ITSUser";
}

- (BOOL)isOnline{
  NSDate *now = [NSDate date];
  NSInteger timeLeft = IT_ONLINE_TIME - [now timeIntervalSinceDate: self.lastOnline];
  return timeLeft > 0;
}

@end
