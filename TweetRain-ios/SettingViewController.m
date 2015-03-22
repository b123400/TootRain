//
//  SettingViewController.m
//  TweetRain
//
//  Created by b123400 on 16/3/15.
//  Copyright (c) 2015 b123400. All rights reserved.
//

#import "SettingViewController.h"
#import "SettingAccountTableViewController.h"
#import "SettingManager.h"

@interface SettingViewController () <SettingAccountTableViewControllerDelegate>

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqualToString:@"account"]) {
        SettingAccountTableViewController *controller = [segue destinationViewController];
        controller.delegate = self;
    }
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark table view

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
}

#pragma mark account

- (void)accountTableViewController:(id)sender didSelectedAccount:(ACAccount *)account {
    [[SettingManager sharedManager] setSelectedAccount:account];
    [[NSNotificationCenter defaultCenter] postNotificationName:ACAccountStoreDidChangeNotification object:nil];
    
    [self.navigationController popToViewController:self animated:NO];
}

@end
