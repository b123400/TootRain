//
//  AuthViewController.h
//  TweetRain
//
//  Created by b123400 on 16/3/15.
//  Copyright (c) 2015 b123400. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AuthViewControllerDelegate <NSObject>

- (void)authViewControllerDidAuthed:(id)sender;
//- (void)authViewControllerDidCanceled:(id)sender;
//- (void)authViewController:(id)sender didFailedWithError:(NSError*)error;

@end

@interface AuthViewController : UIViewController

@property (nonatomic, weak) id <AuthViewControllerDelegate> delegate;

+ (BOOL)authed;

- (instancetype)init;

@end
