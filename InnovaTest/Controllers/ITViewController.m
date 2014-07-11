//
//  ITViewController.m
//  InnovaTest
//
//  Created by Nikita Anisimov on 11/07/14.
//  Copyright (c) 2014 Nikita Anisimov. All rights reserved.
//

#import "ITViewController.h"

#import <Parse/Parse.h>
#import "ITOnlineList.h"

#import "ITUserManager.h"

@interface ITViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, weak) IBOutlet UIButton *presenceButton;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *timeLabel;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;

@property (nonatomic, strong) NSTimer *countDown;

- (IBAction)switchPresence:(id)sender;
- (void)refreshLabelForOnline;
- (void)checkTime;

@end

@implementation ITViewController

- (void)refreshLabelForOnline{
  ITSUser *user = [[ITUserManager sharedManager] user];
  [self.presenceButton setTitle:[user isOnline]?@"Я ушел":@"Я здесь"
                       forState:UIControlStateNormal];
}

- (void)switchPresence:(id)sender{
  ITSUser *user = [[ITUserManager sharedManager] user];
  if ([user isOnline]){
    user.lastOnline = [NSDate dateWithTimeIntervalSince1970:0];
    [user saveInBackground];
  }else{
    user.lastOnline = [NSDate date];
    [user saveInBackground];
  }
  [self refreshLabelForOnline];
}

- (void)checkTime{
  ITSUser *user = [[ITUserManager sharedManager] user];
  NSDate *now = [NSDate date];
  NSInteger timeLeft = IT_ONLINE_TIME - [now timeIntervalSinceDate: user.lastOnline];
  self.timeLabel.text = secondsToFormat(timeLeft <= 0 ? 0 : timeLeft);
  [self refreshLabelForOnline];
}

#pragma mark - Lifecycle

- (void)viewDidLoad
{
  [super viewDidLoad];
//  Set online list target = our tableView
//  So after successful refresh it will call reload
//  Ofcource i could do standard protocol and delegation, but boilerplates etc...
  [[ITOnlineList sharedList] setTarget:self.tableView];
//  Add self as oserver of current user manager
  [[ITUserManager sharedManager] addObserver:self
                                  forKeyPath:@"state"
                                     options:0
                                     context:NULL];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context{
  if ([object isEqual:[ITUserManager sharedManager]]){
    ITUserManager *manager = (ITUserManager*)object;
    switch (manager.state) {
      case ITUserManagerFetching:
        NSLog(@"Fetching");
        break;
      case ITUserManagerReady:
//        Run timers and change labels
        self.countDown = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                          target:self
                                                        selector:@selector(checkTime)
                                                        userInfo:nil
                                                         repeats:YES];
        [self.countDown fire];
        [self.indicator stopAnimating];
        [self refreshLabelForOnline];
        self.presenceButton.userInteractionEnabled = YES;
        break;
      default:
        break;
    }
  }
}

#pragma mark - Table view delegates/dataSources

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
  return 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section{
  return section == 0 ? @"Пользователи online" : @"";
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section{
  return [[ITOnlineList sharedList] onlineUsers].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath{
  static NSString *cellId = @"OnlineCellId";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellId];
  if (!cell){
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                  reuseIdentifier:cellId];
  }
  ITSUser *user = [[ITOnlineList sharedList] onlineUsers][indexPath.row];
  cell.textLabel.text = user[@"UDID"];
  cell.textLabel.textColor = user.lastOnline==nil?[UIColor lightGrayColor]:[UIColor blackColor];
  return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
  [tableView deselectRowAtIndexPath:indexPath
                           animated:YES];
}

@end

NSString* secondsToFormat(NSUInteger secs){
  NSUInteger m = (secs / 60) % 60;
  NSUInteger s = secs % 60;
  return [NSString stringWithFormat:@"%02u:%02u", m, s];
}
