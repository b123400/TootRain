//
//  ViewController.m
//  TweetRain
//
//  Created by b123400 on 25/1/15.
//  Copyright (c) 2015 b123400. All rights reserved.
//

#import "ViewController.h"
#import "AuthViewController.h"
#import <STTwitter/STTwitter.h>
#import "StreamController.h"

@interface ViewController () <AuthViewControllerDelegate, StreamControllerDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[StreamController shared] setDelegate:self];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    if (![AuthViewController authed]) {
        AuthViewController *controller = [[AuthViewController alloc] init];
        controller.delegate = self;
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        navController.modalInPopover = YES;
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        navController.navigationBarHidden = YES;
        [self presentViewController:navController animated:YES completion:nil];
    } else {
        [self startStreaming];
    }
}

- (void)authViewControllerDidAuthed:(id)sender {
    [self startStreaming];
}

- (void)startStreaming {
    [[StreamController shared] startStreaming];
}

#pragma mark setting

- (IBAction)settingButtonPressed:(UIButton*)sender {
    UIViewController *controller = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingNavigationViewController"];
    controller.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = controller.popoverPresentationController;
    popover.delegate = self;
    popover.sourceRect = [sender frame];
    popover.sourceView = [sender superview];
    [self presentViewController:controller animated:YES completion:nil];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationOverFullScreen;
}

@end
