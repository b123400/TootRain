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
		//[[StatusesManager sharedManager] startStreaming:request];
		[currentRequests addObject:request];
	}
	
	return [[self initWithWindowNibName:@"FloodWindowController"] retain];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	[self setShouldCascadeWindows:NO];
	
    float menuBarHeight=[[[NSApplication sharedApplication] mainMenu] menuBarHeight];
	float totalWidth=[[NSScreen mainScreen] frame].size.width;
	float totalHeight=[[NSScreen mainScreen] frame].size.height-menuBarHeight;
	
	[[self window] setFrame:CGRectMake(0, 0, totalWidth, totalHeight) display:YES];
	
}
#pragma mark stream delegate
-(void)request:(TwitterStreamRequest *)request didReceivedTimelineResult:(Status*)status{
	RainDropViewController *thisViewController=[[RainDropViewController alloc]initWithStatus:status];
	[thisViewController loadView];
	[[thisViewController view] setFrame:CGRectMake(0, [self largestPossibleYForStatus:status], 400, 100)];
	[[[self window] contentView]addSubview: [thisViewController view]];
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
-(float)largestPossibleYForStatus:(Status*)status{
	return self.window.frame.size.height-100;
}

- (IBAction)clicked:(id)sender {
	RainDropViewController *thisViewController=[[RainDropViewController alloc]initWithStatus:nil];
	[thisViewController loadView];
	[[thisViewController view] setFrame:CGRectMake(0, [self largestPossibleYForStatus:nil], 400, 100)];
	[[[self window] contentView]addSubview: [thisViewController view]];
}
@end