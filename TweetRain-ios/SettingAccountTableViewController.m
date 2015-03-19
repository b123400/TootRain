//
//  SettingAccountTableViewController.m
//  TweetRain
//
//  Created by b123400 on 16/3/15.
//  Copyright (c) 2015 b123400. All rights reserved.
//

#import "SettingAccountTableViewController.h"
#import "SettingManager.h"
#import "AuthViewController.h"

@interface SettingAccountTableViewController () <AuthViewControllerDelegate>

@end

@implementation SettingAccountTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Accounts", nil);
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (![AuthViewController authed]) {
        AuthViewController *controller = [[AuthViewController alloc] init];
        controller.delegate = self;
        controller.modalInPopover = YES;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        [self presentViewController:navController animated:YES completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (![AuthViewController authed]) return 0;
    // Return the number of rows in the section.
    return [[SettingManager sharedManager].accountStore accountsWithAccountType:[SettingManager sharedManager].accountType].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
    }
    NSArray *allAccounts = [[SettingManager sharedManager].accountStore accountsWithAccountType:[SettingManager sharedManager].accountType];
    ACAccount *account = [allAccounts objectAtIndex:indexPath.row];
    cell.textLabel.text = [account username];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *allAccounts = [[SettingManager sharedManager].accountStore accountsWithAccountType:[SettingManager sharedManager].accountType];
    ACAccount *account = [allAccounts objectAtIndex:indexPath.row];
    [self.delegate accountTableViewController:self didSelectedAccount:account];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if ([[SettingManager sharedManager].accountStore
         accountsWithAccountType:[SettingManager sharedManager].accountType].count == 0) {
        return @"No account avaiable, please add one in the Setting.app";
    }
    return nil;
}

#pragma mark auth view delegate

- (void)authViewControllerDidAuthed:(id)sender {
    [self.tableView reloadData];
    [self dismissViewControllerAnimated:YES completion:nil];
}

//- (void)authViewControllerDidCanceled:(id)sender {
//    
//}
//
//- (void)authViewController:(id)sender didFailedWithError:(NSError *)error {
//    
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
