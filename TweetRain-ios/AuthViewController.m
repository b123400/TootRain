//
//  AuthViewController.m
//  TweetRain
//
//  Created by b123400 on 16/3/15.
//  Copyright (c) 2015 b123400. All rights reserved.
//

#import "AuthViewController.h"
#import "SettingManager.h"
#import "AuthAccountTableViewController.h"

@interface AuthViewController () <SettingAccountTableViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIButton *authorizeButton;

@end

@implementation AuthViewController

+ (BOOL)authed {
    return [[SettingManager sharedManager].accountType accessGranted];
}

- (instancetype)init {
    self = [super initWithNibName:@"AuthViewController" bundle:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountStoreDidChanged:) name:ACAccountStoreDidChangeNotification object:nil];
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"")
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(closeButtonPressed:)];
    self.authorizeButton.layer.borderColor = [UIColor colorWithRed:42.0/255.0
                                                             green:104.0/255.0
                                                              blue:219/255.0
                                                             alpha:1].CGColor;
    self.authorizeButton.layer.borderWidth = 1;
    self.authorizeButton.layer.cornerRadius = 8;
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
    if ([manager.accountType accessGranted]) {
        [self processAccounts];
        return;
    }
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
                 UIAlertController *alertController = [UIAlertController
                                                       alertControllerWithTitle:NSLocalizedString(@"Error", @"")
                                                       message:error.localizedDescription
                                                       preferredStyle:UIAlertControllerStyleAlert];
                 [alertController addAction:[UIAlertAction actionWithTitle:@"OK"
                                                                     style:UIAlertActionStyleDefault
                                                                   handler:nil]];
                 [self presentViewController:alertController animated:YES completion:nil];
                 return;
             }
             if (!granted) {
                 UIAlertController *alertController = [UIAlertController
                                                       alertControllerWithTitle:NSLocalizedString(@"Oh no!", @"")
                                                       message:NSLocalizedString(@"I need permission to access your Twitter account, otherwise this app is pretty useless. Please go to Setting app --> Privacy and turn on Twitter permission for TweetRain", @"")
                                                       preferredStyle:UIAlertControllerStyleAlert];
                 [alertController addAction:
                  [UIAlertAction actionWithTitle:@"OK"
                                           style:UIAlertActionStyleCancel
                                         handler:^(UIAlertAction *action) {
                                             
                                         }]];
                 [alertController addAction:
                  [UIAlertAction actionWithTitle:NSLocalizedString(@"Teach me how", @"")
                                           style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction *action) {
                                             [[UIApplication sharedApplication]
                                              openURL:[NSURL URLWithString:@"https://support.apple.com/en-us/HT202605"]];
                                         }]];
                 [self presentViewController:alertController animated:YES completion:nil];
                 return;
             }
             [self processAccounts];
         });
     }];
}

- (void)processAccounts {
    SettingManager *manager = [SettingManager sharedManager];
    NSArray *accounts = [manager.accountStore accountsWithAccountType:manager.accountType];
    if (accounts.count == 0) {
        [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Oh on!", @"")
                                    message:NSLocalizedString(@"You haven't setup any Twitter account. Please set it up in the Setting app", @"")
                                   delegate:self
                          cancelButtonTitle:@"OK"
                          otherButtonTitles:@"Teach me how", nil]
         show];
    } else if (accounts.count == 1) {
        [[SettingManager sharedManager] setSelectedAccount:accounts[0]];
        [self.delegate authViewControllerDidAuthed:self];
    } else {
        SettingAccountTableViewController *controller = [[AuthAccountTableViewController alloc] init];
        controller.delegate = self;
        
        [UIView animateWithDuration:0.5 animations:^{
            self.view.layer.opacity = 0;
        } completion:^(BOOL finished) {
            self.view.layer.opacity = 1;
        }];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)accountStoreDidChanged:(NSNotification*)notification {
    if ([self.navigationController topViewController] == self) {
        [self processAccounts];
    }
}

#pragma mark select account

- (void)accountTableViewController:(id)sender didSelectedAccount:(ACAccount *)account {
    [[SettingManager sharedManager] setSelectedAccount:account];
    [[NSNotificationCenter defaultCenter] postNotificationName:ACAccountStoreDidChangeNotification object:nil];
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
