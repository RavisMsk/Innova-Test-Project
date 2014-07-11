//
//  ITAppDelegate.m
//  InnovaTest
//
//  Created by Nikita Anisimov on 11/07/14.
//  Copyright (c) 2014 Nikita Anisimov. All rights reserved.
//

#import "ITAppDelegate.h"

#import <Parse/Parse.h>
#import "ITSUser.h"
#import "ITUserManager.h"

@implementation ITAppDelegate

- (BOOL)application:(UIApplication *)application
didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//  Register new Parse class
  [ITSUser registerSubclass];
//  Setup Parse
  [Parse setApplicationId:@"n9k5RX4jQXan0qi4ow6XKAXcq5oSmqeN9skG1LPa"
                clientKey:@"tFJk7006KCDMH98XtbmWEJFTVn9vmbUPVVIQL5qz"];
  
  return YES;
}

- (void)application:(UIApplication *)application
didReceiveLocalNotification:(UILocalNotification *)notification{
  
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  
  ITSUser *user = [[ITUserManager sharedManager] user];
//  If user is offline right now there is no need in this
  if ([user isOnline]){
    UILocalNotification *local = [[UILocalNotification alloc] init];
//  Find out when user online session ends
    NSDate *offlineDate = [NSDate dateWithTimeInterval:IT_ONLINE_TIME
                                             sinceDate:user.lastOnline];
    local.fireDate = offlineDate;
//  Set message etc.
    local.alertBody = @"Онлайн сессия окончена, вы ушли в офлайн.";
    local.timeZone = [NSTimeZone defaultTimeZone];
//  Schedule it
    [[UIApplication sharedApplication] scheduleLocalNotification:local];
  }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  if ([[UIApplication sharedApplication] scheduledLocalNotifications].count > 0){
    UILocalNotification *note = [[UIApplication sharedApplication] scheduledLocalNotifications][0];
    [[UIApplication sharedApplication] cancelLocalNotification:note];
  }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
  // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
