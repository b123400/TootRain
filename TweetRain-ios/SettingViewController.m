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
#import "SettingColorViewController.h"

@interface SettingViewController () <SettingAccountTableViewControllerDelegate, SettingColorViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIView *textColorView;
@property (weak, nonatomic) IBOutlet UIView *textShadowColorView;
@property (weak, nonatomic) IBOutlet UISlider *opacitySlider;
@property (weak, nonatomic) IBOutlet UIStepper *fontSizeStepper;
@property (weak, nonatomic) IBOutlet UILabel *fontSizeLabel;

@end

@implementation SettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
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
    } else if ([segue.identifier isEqualToString:@"font"]) {
        
    }
}

- (IBAction)closeButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark table view

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    if ([[cell reuseIdentifier] isEqualToString:@"textColor"]) {
        self.textColorView.backgroundColor = [SettingManager sharedManager].textColor;
        self.textColorView.layer.borderColor = [UIColor blackColor].CGColor;
        self.textColorView.layer.borderWidth = 1;
        
    } else if ([[cell reuseIdentifier] isEqualToString:@"shadowColor"]) {
        self.textShadowColorView.backgroundColor = [SettingManager sharedManager].shadowColor;
        self.textShadowColorView.layer.borderColor = [UIColor blackColor].CGColor;
        self.textShadowColorView.layer.borderWidth = 1;
        
    } else if ([[cell reuseIdentifier] isEqualToString:@"fontSize"]) {
        self.fontSizeStepper.value = [SettingManager sharedManager].fontSize;
        self.fontSizeLabel.text = [NSString stringWithFormat:NSLocalizedString(@"Font size: %lu px", @""),
                                   (unsigned long)[SettingManager sharedManager].fontSize];
        
    } else if ([[cell reuseIdentifier] isEqualToString:@"opacity"]) {
        self.opacitySlider.value = [SettingManager sharedManager].opacity;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if ([[cell reuseIdentifier] isEqualToString:@"textColor"]) {
        SettingColorViewController *controller = [[SettingColorViewController alloc] initWithColor:[SettingManager sharedManager].textColor];
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    } else if ([[cell reuseIdentifier] isEqualToString:@"shadowColor"]) {
        SettingColorViewController *controller = [[SettingColorViewController alloc] initWithColor:[SettingManager sharedManager].shadowColor];
        controller.delegate = self;
        [self.navigationController pushViewController:controller animated:YES];
    }
}


#pragma mark interaction

- (void)settingColorViewController:(id)sender didSelectedColor:(UIColor *)color {
    NSString *identifier = [[self.tableView cellForRowAtIndexPath:self.tableView.indexPathForSelectedRow] reuseIdentifier] ;
    if ([identifier isEqualToString:@"textColor"]) {
        [[SettingManager sharedManager] setTextColor:color];
        self.textColorView.backgroundColor = color;
    } else if ([identifier isEqualToString:@"shadowColor"]) {
        [[SettingManager sharedManager] setShadowColor:color];
        self.textShadowColorView.backgroundColor = color;
    }
}

- (IBAction)fontSizeStepperValueChanged:(UIStepper*)sender {
    [[SettingManager sharedManager] setFontSize:sender.value];
    [self.tableView reloadData];
}

- (IBAction)opacitySliderValueChanged:(UISlider*)sender {
    [[SettingManager sharedManager] setOpacity:sender.value];
}

#pragma mark account

- (void)accountTableViewController:(id)sender didSelectedAccount:(ACAccount *)account {
    [[SettingManager sharedManager] setSelectedAccount:account];
    [[NSNotificationCenter defaultCenter] postNotificationName:ACAccountStoreDidChangeNotification object:nil];

    [self.navigationController popToViewController:self animated:NO];
}

@end
