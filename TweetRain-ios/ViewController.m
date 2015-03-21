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
#import "SettingManager.h"
#import "StreamController.h"
#import "Status.h"
#import "RainDropViewController.h"

@interface ViewController () <AuthViewControllerDelegate, StreamControllerDelegate, RainDropViewControllerDelegate>

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
    if (![AuthViewController authed] || ![SettingManager sharedManager].selectedAccount) {
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
    if ([self presentedViewController]) {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
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

#pragma mark stream

- (void)streamController:(id)controller didReceivedTweet:(Status*)tweet {
    RainDropViewController *rainDropController = [[RainDropViewController alloc] initWithStatus:tweet];
    rainDropController.delegate = self;
    [self.view addSubview:rainDropController.view];
    [self addChildViewController:rainDropController];
    
    CGRect frame = rainDropController.view.frame;
    frame.origin.x = self.view.frame.size.width;
    frame.origin.y = [self smallestPossibleYForStatusViewController:rainDropController];
    rainDropController.view.frame = frame;
    
    [rainDropController startAnimation];
}

-(float)ySuggestionForStatusViewController:(RainDropViewController*)controller atY:(float)thisY{
    float minY=thisY;
    
    for(RainDropViewController *thisController in self.childViewControllers){
        if (![thisController isKindOfClass:[RainDropViewController class]]) continue;
        if ((thisController.view.frame.origin.y<=thisY&&
             thisController.view.frame.origin.y+thisController.view.frame.size.height>=thisY)||
            (thisController.view.frame.origin.y<=thisY+controller.view.frame.size.height&&
             thisController.view.frame.origin.y>=thisY)){
               //y position overlap
               if([thisController willCollideWithRainDrop:controller]){
                   minY = CGRectGetMaxY(thisController.view.frame) + 1;
               }
           }
    }
    return minY;
}

-(float)smallestPossibleYForStatusViewController:(RainDropViewController*)controller{
    float possibleY = 0;
    while(possibleY < self.view.frame.size.height){
        float suggestion = [self ySuggestionForStatusViewController:controller atY:possibleY];
        if(suggestion == possibleY){
            break;
        }
        possibleY=suggestion;
    }
    return possibleY;
}

#pragma mark interaction

- (void)rainDropViewControllerDidDisappeared:(RainDropViewController*)sender {
    [sender.view removeFromSuperview];
    [sender removeFromParentViewController];
    sender.delegate = nil;
}

- (void)rainDropViewControllerDidTapped:(RainDropViewController*)sender {
    NSLog(@"did tapped %@", sender.status.text);
}

@end
