//
//  AuthViewController.m
//  TweetRain
//
//  Created by b123400 on 16/3/15.
//  Copyright (c) 2015 b123400. All rights reserved.
//

#import "AuthViewController.h"
#import "SettingManager.h"
#import "SettingAccountTableViewController.h"

@interface AuthViewController () <SettingAccountTableViewControllerDelegate>

@end

@implementation AuthViewController

+ (BOOL)authed {
    return [[SettingManager sharedManager].accountType accessGranted];
}

- (instancetype)init {
    self = [super initWithNibName:@"AuthViewController" bundle:nil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(closeButtonPressed:)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)authorizeButtonPressed:(id)sender {
    SettingManager *manager = [SettingManager sharedManager];
    [manager.accountStore
     requestAccessToAccountsWithType:manager.accountType
     options:nil
     completion:^(BOOL granted, NSError *error) {
         dispatch_async(dispatch_get_main_queue(), ^{
             if (error) {
                 [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"")
                                             message:error.localizedDescription
                                            delegate:nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles: nil]
                  show];
                 return;
             }
             if (!granted) {
                 [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oh no!", @"")
                                             message:NSLocalizedString(@"I need permission to access your Twitter account, otherwise this app is pretty useless. Please go to Setting app --> Privacy and turn on Twitter permission for TWeetRain", @"")
                                            delegate:nil
                                   cancelButtonTitle:NSLocalizedString(@"OK", nil)
                                   otherButtonTitles: nil]
                  show];
                 return;
             }
             NSArray *accounts = [manager.accountStore accountsWithAccountType:manager.accountType];
             if (accounts.count == 0) {
                 // no account view
             } else if (accounts.count == 1) {
                 [[SettingManager sharedManager] setSelectedAccount:accounts[0]];
                 [self.delegate authViewControllerDidAuthed:self];
             } else {
                 SettingAccountTableViewController *controller = [[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"SettingAccountTableViewController"];
                 controller.delegate = self;
                 [self.navigationController pushViewController:controller animated:YES];
             }
         });
     }];
}

#pragma mark select account

- (void)accountTableViewController:(id)sender didSelectedAccount:(ACAccount *)account {
    [[SettingManager sharedManager] setSelectedAccount:account];
    [self.delegate authViewControllerDidAuthed:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
