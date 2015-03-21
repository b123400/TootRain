//
//  RainDropViewController.h
//  TweetRain
//
//  Created by b123400 on 20/3/15.
//
//

#import <UIKit/UIKit.h>
#import "Status.h"

@protocol RainDropViewControllerDelegate <NSObject>

@optional
- (void)rainDropViewControllerDidDisappeared:(id)sender;
- (void)rainDropViewControllerDidTapped:(id)sender;

@end

@interface RainDropViewController : UIViewController

@property (nonatomic, strong) Status *status;
@property (nonatomic, weak) id <RainDropViewControllerDelegate> delegate;

- (instancetype)initWithStatus:(Status*)status;

- (void)startAnimation;
- (void)pauseAnimation;

-(BOOL)paused;

-(float)animationDuration;
-(float)durationUntilDisappear;
-(float)durationBeforeReachingEdge;

-(BOOL)willCollideWithRainDrop:(RainDropViewController*)controller;

@end
