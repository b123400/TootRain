//
//  ViewController.m
//  TweetRain
//
//  Created by b123400 on 25/1/15.
//  Copyright (c) 2015 b123400. All rights reserved.
//

#import "ViewController.h"
#import "AuthViewController.h"
//#import <STTwitter/STTwitter.h>
#import "SettingManager.h"
#import "StreamController.h"
#import "Status.h"
#import "RainDropViewController.h"
#import "RainDropDetailViewController.h"
#import "BRNavigationViewController.h"
#import <UIImage+ImageEffects.h>
#import "StreamController.h"
#import "BRSearchViewController.h"

@interface ViewController () <AuthViewControllerDelegate, StreamControllerDelegate, RainDropViewControllerDelegate, RainDropDetailViewControllerDelegate, BRSearchViewControllerDelegate>

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

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (void)viewDidAppear:(BOOL)animated {
    if (![AuthViewController authed] || ![SettingManager sharedManager].selectedAccount) {
        AuthViewController *controller = [[AuthViewController alloc] init];
        controller.delegate = self;
        
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:controller];
        navController.modalPresentationStyle = UIModalPresentationFormSheet;
        navController.navigationBarHidden = YES;
        navController.view.backgroundColor = [UIColor clearColor];
        
        UIGraphicsBeginImageContextWithOptions(self.view.frame.size, YES, 0);
        [self.view drawViewHierarchyInRect:self.view.frame afterScreenUpdates:NO];
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        // create dark blurred image, requires UIImage+ImageEffects
        UIImage *blurredImage = [image applyBlurWithRadius:20
                                                 tintColor:[UIColor colorWithWhite:1 alpha:0.75]
                                     saturationDeltaFactor:2
                                                 maskImage:nil];
        
        [self presentViewController:navController animated:NO completion:^{
            CGRect frame = [self.view convertRect:CGRectMake(0,
                                                             0,
                                                             self.view.frame.size.width,
                                                             self.view.frame.size.height)
                                           toView:navController.view];
            if (frame.origin.x == 0 && frame.origin.y == 0) {
                // On iPhone (fullscreen present), convert rect works differently
                // it returns a scaled version, so scale it back
                CGFloat scale = [UIScreen mainScreen].scale;
                frame.origin.x *= scale;
                frame.origin.y *= scale;
                frame.size.width *= scale;
                frame.size.height *= scale;
            }
            
            UIImageView *blurImageView = [[UIImageView alloc] initWithImage:blurredImage];
            blurImageView.frame = frame;
            [navController.view addSubview:blurImageView];
            [navController.view sendSubviewToBack:blurImageView];
        }];
        
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

#pragma mark search

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([[segue identifier] isEqualToString:@"Search"]) {
        UINavigationController *navController = [segue destinationViewController];
        BRSearchViewController *controller = (BRSearchViewController*)[navController topViewController];
        controller.delegate = self;
        controller.searchTerm = [StreamController shared].searchTerm;
    }
}

#pragma mark - Search

- (void)searchViewController:(id)controller didEnteredSearchTerm:(NSString *)searchTerm {
    if ([searchTerm isEqualToString:@""]) {
        [StreamController shared].searchTerm = nil;
    } else {
        [StreamController shared].searchTerm = searchTerm;
    }
    [controller dismissViewControllerAnimated:YES completion:nil];
}

- (void)searchViewControllerDidCancelled:(id)controller {
    [controller dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark interface

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationOverFullScreen;
}


- (UIViewController *)presentationController:(UIPresentationController *)controller
  viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
    UIViewController *dest = [controller presentedViewController];
    if (![dest isKindOfClass:[UINavigationController class]]) {
        BRNavigationViewController *controller = [[BRNavigationViewController alloc] initWithRootViewController:dest];
        return controller;
    }
    return dest;
}

#pragma mark stream

- (void)streamController:(id)controller didReceivedTweet:(Status*)tweet {
    RainDropViewController *rainDropController = [[RainDropViewController alloc] initWithStatus:tweet];
    rainDropController.delegate = self;
    [self.view addSubview:rainDropController.view];
    
    CGRect frame = rainDropController.view.frame;
    frame.origin.x = self.view.frame.size.width;
    CGFloat y = [self smallestPossibleYForStatusViewController:rainDropController];
    if (y == -1) {
        // outside of view = dont show
        [rainDropController.view removeFromSuperview];
        rainDropController.delegate = nil;
        return;
    }
    frame.origin.y = y;
    rainDropController.view.frame = frame;
    
    [self addChildViewController:rainDropController];
    
    [rainDropController startAnimation];
}

-(float)ySuggestionForStatusViewController:(RainDropViewController*)controller atY:(float)thisY{
    float minY=thisY;
    
    for(RainDropViewController *thisController in self.childViewControllers){
        if (![thisController isKindOfClass:[RainDropViewController class]]) continue;
        if (thisController == controller) continue;
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
    float possibleY = self.topLayoutGuide.length;
    while(possibleY < self.view.frame.size.height){
        float suggestion = [self ySuggestionForStatusViewController:controller atY:possibleY];
        if(suggestion == possibleY){
            return possibleY;
        }
        possibleY=suggestion;
    }
    return -1;
}

- (void)rainDropViewControllerDidDisappeared:(RainDropViewController*)sender {
    [sender.view removeFromSuperview];
    [sender removeFromParentViewController];
    sender.delegate = nil;
}

#pragma mark interaction

- (void)rainDropViewControllerDidTapped:(RainDropViewController*)sender {
    RainDropDetailViewController *detailViewController = [[RainDropDetailViewController alloc] initWithStatus:sender.status];
    detailViewController.delegate = self;
    detailViewController.modalPresentationStyle = UIModalPresentationPopover;
    UIPopoverPresentationController *popover = detailViewController.popoverPresentationController;
    popover.sourceRect = CGRectMake(
                                    [sender.view.layer.presentationLayer frame].origin.x,
                                    sender.view.layer.frame.origin.y,
                                    sender.view.layer.frame.size.width,
                                    sender.view.layer.frame.size.height);
    popover.sourceView = self.view;
    popover.delegate = self;
    popover.backgroundColor = [UIColor clearColor];
    [self presentViewController:detailViewController animated:YES completion:nil];
    [sender pauseAnimation];
}

- (void)popoverPresentationControllerDidDismissPopover:(UIPopoverPresentationController *)popoverPresentationController {
    if ([popoverPresentationController.presentedViewController isKindOfClass:[RainDropDetailViewController class]]) {
        [self rainDropDetailViewControllerDidClosed:(RainDropDetailViewController*)popoverPresentationController.presentedViewController];
    }
}

- (void)rainDropDetailViewControllerDidClosed:(RainDropDetailViewController*)sender {
    Status *status = sender.status;
    for (RainDropViewController *raindrop in self.childViewControllers) {
        if (![raindrop isKindOfClass:[RainDropViewController class]]) continue;
        if ([raindrop status] == status) {
            [raindrop startAnimation];
        }
    }
}

@end
