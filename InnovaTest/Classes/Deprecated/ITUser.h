//
//  ITUser.h
//  InnovaTest
//
//  Created by Nikita Anisimov on 11/07/14.
//  Copyright (c) 2014 Nikita Anisimov. All rights reserved.
//

#import <Parse/Parse.h>

typedef void (^ITUserTimeLeftBlock)(NSUInteger timeLeft);
typedef void (^ITUserCheckOnlineBlock)(BOOL online);

@interface ITUser : PFObject<PFSubclassing>

+ (void)setOnlineState:(BOOL)onLine;
+ (void)onlineTimeLeft:(ITUserTimeLeftBlock)h;
+ (void)checkMyOnline:(ITUserCheckOnlineBlock)h;

@end
