//
//  ITSUser.h
//  InnovaTest
//
//  Created by Nikita Anisimov on 11/07/14.
//  Copyright (c) 2014 Nikita Anisimov. All rights reserved.
//

#import <Parse/Parse.h>

@interface ITSUser : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *UDID;
@property (nonatomic, strong) NSDate *lastOnline;

- (BOOL)isOnline;

@end
