//
//  RainViewController.h
//  flood
//
//  Created by b123400 on 12/8/12.
//
//

#import <Cocoa/Cocoa.h>
#import "Status.h"
#import "RainDropView.h"
#import "WebImageView.h"

@protocol RainDropViewControllerDelegate

-(void)rainDropDidDisappear:(id)rainDrop;

@end

@interface RainDropViewController : NSViewController <RainDropViewDelegate,NSPopoverDelegate> {
	NSTextField *contentTextField;
	
	Status *status;
	NSDate *animationEnd;
	
	id delegate;
	
	BOOL paused;
	float margin;
	
	NSPopover *popover;
	IBOutlet WebImageView *profileImageView;
}

@property (assign) IBOutlet NSTextField *contentTextField;
@property (retain,nonatomic) Status *status;
@property (assign,nonatomic) id delegate;

- (id)initWithStatus:(Status*)_status;

-(void)startAnimation;
-(void)pauseAnimation;
-(BOOL)paused;
-(BOOL)isPopoverShown;

-(float)animationDuration;
-(float)durationUntilDisappear;
-(float)durationBeforeReachingEdge;

-(BOOL)willCollideWithRainDrop:(RainDropViewController*)controller;

-(CGRect)visibleFrame;

-(void)didMouseOver;
-(void)didMouseOut;

@end
