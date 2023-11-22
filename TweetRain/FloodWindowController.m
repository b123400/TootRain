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
#import "RainDropViewController.h"
#import "SettingViewController.h"
#import "MastodonStatus.h"
#import "BRMastodonStatus.h"
#import "History Window/HistoryWindowController.h"

@interface FloodWindowController ()

-(BOOL)shouldShowStatus:(Status*)status;
-(float)largestPossibleYForStatusViewController:(RainDropViewController*)status;

@end

@implementation FloodWindowController

-(id)init{
    self.rainDrops=[[NSMutableArray alloc]init];
    
	timer=[NSTimer scheduledTimerWithTimeInterval:0.1
										   target:self
										 selector:@selector(updateCursorLocation:)
										 userInfo:nil
										  repeats:YES];
	lastMousePosition = CGPointZero;
    shownStatusIds = [[NSMutableSet alloc] init];
    
    [StreamController shared].delegate = self;
    [[StreamController shared] startStreaming];
	
	return [self initWithWindowNibName:@"FloodWindowController"];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)windowDidLoad
{
    [super windowDidLoad];
	[self setShouldCascadeWindows:NO];
	
    [self resetFrame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame) name:kWindowScreenChanged object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame) name:kWindowLevelChanged object:nil];
    [self.window setCollectionBehavior: NSWindowCollectionBehaviorCanJoinAllSpaces | NSWindowCollectionBehaviorFullScreenAuxiliary];
}

-(void)resetFrame {
    WindowLevel savedWindowLevel = [[SettingManager sharedManager] windowLevel];
    NSUInteger windowLevel = NSFloatingWindowLevel;
    float menuBarHeight = [[[NSApplication sharedApplication] mainMenu] menuBarHeight];
    switch (savedWindowLevel) {
        case WindowLevelAboveMenuBar:
            windowLevel = CGShieldingWindowLevel();
            menuBarHeight = 0;
            break;
        case WindowLevelAboveAllWindows:
            windowLevel = NSFloatingWindowLevel;
            break;
        case WindowLevelAboveDesktop:
            windowLevel = kCGDesktopIconWindowLevel+1;
            break;
        default:
            break;
    }
    [self.window setLevel:windowLevel];
    CGRect screenFrame = self.window.screen.frame;
	float totalWidth = screenFrame.size.width;
	float totalHeight = screenFrame.size.height - menuBarHeight;
	
	[[self window] setFrame:CGRectMake(screenFrame.origin.x, screenFrame.origin.y, totalWidth, totalHeight) display:YES];
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];
    [self resetFrame];
}

#pragma mark stream delegate
-(void)streamController:(id)controller didReceivedStatus:(Status *)status {
    typeof(self) __weak _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![_self shouldShowStatus:status]) return;
        
        RainDropViewController *thisViewController=[[RainDropViewController alloc]initWithStatus:status];
        [thisViewController loadView];
        CGRect frame=thisViewController.view.frame;
        frame.origin.y=[_self largestPossibleYForStatusViewController:thisViewController];
        if (frame.origin.y < 0) {
            // out of screen, discard
            return;
        }
        thisViewController.view.frame=frame;
        [[[_self window] contentView]addSubview: [thisViewController view]];
        thisViewController.delegate=self;
        [self.rainDrops addObject:thisViewController];
        
        [[HistoryWindowController shared] addStatus:status];
    });
}

-(BOOL)shouldShowStatus:(Status*)status{
	if([shownStatusIds containsObject:status.statusID]){
		return NO;
	}
    if (status.statusID != nil) {
        // nil used for special raindrops like notification
        [shownStatusIds addObject:status.statusID];
    }
	return YES;
}
#pragma mark position calculation
-(float)ySuggestionForStatusViewController:(RainDropViewController*)controller atY:(float)thisY{
	float minY=thisY;
	for(RainDropViewController *thisController in self.rainDrops){
		if((thisController.view.frame.origin.y<=thisY&&
			thisController.view.frame.origin.y+thisController.view.frame.size.height>=thisY)||
		   (thisController.view.frame.origin.y<=thisY+controller.view.frame.size.height&&
			thisController.view.frame.origin.y>=thisY)){
			//y position overlap
			if([thisController willCollideWithRainDrop:controller]){
				minY=thisController.view.frame.origin.y-controller.view.frame.size.height-1;
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
-(void)rainDropDidDisappear:(RainDropViewController*)rainDrop{
	[[rainDrop view] removeFromSuperview];
	[self.rainDrops removeObject:rainDrop];
    if (rainDrop.status.statusID != nil) {
        [shownStatusIds removeObject:rainDrop.status.statusID];
    }
}

- (void)updateCursorLocation:(NSEvent*)event {
	NSPoint mouseLoc = [self.window mouseLocationOutsideOfEventStream];
	CGPoint point = NSPointToCGPoint(mouseLoc);
    CursorBehaviour cursorBehaviour = [[SettingManager sharedManager] cursorBehaviour];
    BOOL windowShouldIgnoreMouse = YES;
	if (!CGPointEqualToPoint(lastMousePosition,point)) {
		lastMousePosition = point;
		//moved
		for (RainDropViewController *thisController in self.rainDrops) {
			if ([thisController isPopoverShown]) {
				//a raindrop is already paused
                windowShouldIgnoreMouse = NO;
                [self.window setIgnoresMouseEvents:NO];
				return;
			}
		}
		for (RainDropViewController *thisController in self.rainDrops) {
			CGRect rect = [thisController visibleFrame];
			if (CGRectContainsPoint(rect, point)) {
                if (cursorBehaviour == CursorBehaviourPause) {
                    windowShouldIgnoreMouse = NO;
                }
				if (![thisController paused]) {
					[thisController didMouseOver];
				}
			} else {
				[thisController didMouseOut];
			}
		}
        [self.window setIgnoresMouseEvents:windowShouldIgnoreMouse];
	}
}
- (void)mouseUp:(NSEvent *)event {
    NSPoint mouseLoc = [self.window mouseLocationOutsideOfEventStream];
    CGPoint point = NSPointToCGPoint(mouseLoc);
    for (RainDropViewController *thisController in self.rainDrops) {
        CGRect rect = [thisController visibleFrame];
        if (CGRectContainsPoint(rect, point)) {
            [thisController viewDidClicked:self];
            return;
        }
    }
    [super mouseUp:event];
}
@end
