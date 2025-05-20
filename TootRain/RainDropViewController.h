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
#import "BRAnimatedTextField.h"

@protocol RainDropViewControllerDelegate

-(void)rainDropDidDisappear:(id)rainDrop;

@end

@interface RainDropViewController : NSViewController <RainDropViewDelegate,NSPopoverDelegate> {
    BRAnimatedTextField *__weak contentTextField;
	
	Status *status;
	NSDate *animationEnd;
	
	id __unsafe_unretained delegate;
	
	BOOL paused;
	float margin;
	
	NSPopover *popover;
	IBOutlet WebImageView *profileImageView;
}

@property (weak) IBOutlet NSTextField *contentTextField;
@property (strong,nonatomic) Status *status;
@property (unsafe_unretained,nonatomic) id delegate;

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
