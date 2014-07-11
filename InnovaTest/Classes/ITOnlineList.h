//
//  ITOnlineList.h
//  InnovaTest
//
//  Created by Nikita Anisimov on 11/07/14.
//  Copyright (c) 2014 Nikita Anisimov. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ITOnlineList : NSObject

@property (nonatomic, strong) NSArray *onlineUsers;

@property (nonatomic, weak) UITableView *target;

+ (instancetype)sharedList;

@end
