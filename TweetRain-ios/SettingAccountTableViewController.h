//
//  SettingAccountTableViewController.h
//  TweetRain
//
//  Created by b123400 on 16/3/15.
//  Copyright (c) 2015 b123400. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Accounts/Accounts.h>

@protocol SettingAccountTableViewControllerDelegate <NSObject>

- (void)accountTableViewController:(id)sender didSelectedAccount:(ACAccount*)account;

@end

@interface SettingAccountTableViewController : UITableViewController

@property (nonatomic, strong) id <SettingAccountTableViewControllerDelegate> delegate;

@end
