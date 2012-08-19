//
//  FloodWindowController.m
//  flood
//
//  Created by b123400 on 11/8/12.
//
//
#import <QuartzCore/QuartzCore.h>
#import "FloodWindowController.h"
#import "SettingManager.h"
#import "TwitterStreamRequest.h"
#import "StatusesManager.h"
#import "RainDropViewController.h"

@interface FloodWindowController ()

-(float)largestPossibleYForStatusViewController:(RainDropViewController*)status;

@end

@implementation FloodWindowController

-(id)init{
	
	currentRequests=[[NSMutableArray alloc] init];
	rainDrops=[[NSMutableArray alloc]init];
	
	/*start stream*/
	for(Account *thisAccount in [[SettingManager sharedManager] accounts]){
		TwitterStreamRequest *request=[[[TwitterStreamRequest alloc] init]autorelease];
		request.target=self;
		request.timelineSelector=@selector(request:didReceivedTimelineResult:);
		request.mentionSelector=@selector(request:didReceivedMentionResult:);
		request.directMessageSelector=@selector(request:didReceivedDirectMessageResult:);
		request.eventSelector=@selector(request:didReceivedEvent:);
		request.failSelector=@selector(request:failedWithError:);
		request.account=thisAccount;
		[[StatusesManager sharedManager] startStreaming:request];
		[currentRequests addObject:request];
	}
	timer=[NSTimer scheduledTimerWithTimeInterval:0.1
										   target:self
										 selector:@selector(updateCursorLocation:)
										 userInfo:nil
										  repeats:YES];
	lastMousePosition=CGPointZero;
	
	return [[self initWithWindowNibName:@"FloodWindowController"] retain];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	[self setShouldCascadeWindows:NO];
	
    [self resetFrame];
}
-(void)resetFrame{
	float menuBarHeight=[[[NSApplication sharedApplication] mainMenu] menuBarHeight];
	if([[SettingManager sharedManager]overlapsMenuBar]){
		menuBarHeight=0;
		[self.window setLevel:CGShieldingWindowLevel()];
	}else{
		[self.window setLevel:NSFloatingWindowLevel];
	}
	float totalWidth=[[NSScreen mainScreen] frame].size.width;
	float totalHeight=[[NSScreen mainScreen] frame].size.height-menuBarHeight;
	
	[[self window] setFrame:CGRectMake(0, 0, totalWidth, totalHeight) display:YES];
}
#pragma mark stream delegate
-(void)request:(TwitterStreamRequest *)request didReceivedTimelineResult:(Status*)status{
	RainDropViewController *thisViewController=[[RainDropViewController alloc]initWithStatus:status];
	[thisViewController loadView];
	CGRect frame=thisViewController.view.frame;
	frame.origin.y=[self largestPossibleYForStatusViewController:thisViewController];
	thisViewController.view.frame=frame;
	[[[self window] contentView]addSubview: [thisViewController view]];
	thisViewController.delegate=self;
	[rainDrops addObject:thisViewController];
	[thisViewController release];
}
-(void)request:(TwitterStreamRequest *)request didReceivedMentionResult:(Status*)status{
	
}

-(void)request:(TwitterStreamRequest *)request didReceivedDirectMessageResult:(Status*)status{
	
}

-(void)request:(SearchRequest *)request didReceivedSearchResult:(Status*)status{
	
}

-(void)request:(TwitterStreamRequest *)request didReceivedEvent:(id)event{
	
}
#pragma mark position calculation
-(float)ySuggestionForStatusViewController:(RainDropViewController*)controller atY:(float)thisY{
	float minY=thisY;
	for(RainDropViewController *thisController in rainDrops){
		if((thisController.view.frame.origin.y<=thisY&&
			thisController.view.frame.origin.y+thisController.view.frame.size.height>=thisY)||
		   (thisController.view.frame.origin.y<=thisY+controller.view.frame.size.height&&
			thisController.view.frame.origin.y>=thisY)){
			//y position overlap
			if([thisController willCollideWithRainDrop:controller]){
				minY=thisController.view.frame.origin.y-controller.view.frame.size.height+1;
			}
		}
	}
	return minY;
}
-(float)largestPossibleYForStatusViewController:(RainDropViewController*)controller{
	float possibleY=self.window.frame.size.height-controller.view.frame.size.height;
	while(possibleY>0){
		float suggestion=[self ySuggestionForStatusViewController:controller atY:possibleY];
		if(suggestion==possibleY){
			break;
		}
		possibleY=suggestion;
	}
	return possibleY;
}
#pragma mark animation
-(void)rainDropDidDisappear:(id)rainDrop{
	[[rainDrop view] removeFromSuperview];
	[rainDrops removeObject:rainDrop];
}

-(void)updateCursorLocation:(NSEvent*)event{
	NSPoint mouseLoc = [NSEvent mouseLocation];
	CGPoint point=NSPointToCGPoint(mouseLoc);
	if(!CGPointEqualToPoint(lastMousePosition,point)){
		lastMousePosition=point;
		//moved
		BOOL popoverShown=false;
		for(RainDropViewController *thisController in rainDrops){
			if([thisController isPopoverShown]){
				//a raindrop is already paused
				popoverShown=true;
				return;
			}
		}
		for(RainDropViewController *thisController in rainDrops){
			CGRect rect=[thisController visibleFrame];
			if(CGRectContainsPoint(rect, point)){
				if(![thisController paused]&&!popoverShown){
					[thisController didMouseOver];
				}
			}else{
				[thisController didMouseOut];
			}
		}
	}
}
@end