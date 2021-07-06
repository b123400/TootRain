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

@interface FloodWindowController ()

-(BOOL)shouldShowStatus:(Status*)status;
-(float)largestPossibleYForStatusViewController:(RainDropViewController*)status;

@end

@implementation FloodWindowController

-(id)init{
	
	currentRequests=[[NSMutableArray alloc] init];
	rainDrops=[[NSMutableArray alloc]init];
    
	timer=[NSTimer scheduledTimerWithTimeInterval:0.1
										   target:self
										 selector:@selector(updateCursorLocation:)
										 userInfo:nil
										  repeats:YES];
	lastMousePosition=CGPointZero;
	shownStatuses=[[NSMutableArray alloc] init];
    
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetFrame) name:kWindowLevelChanged object:nil];
}

-(void)resetFrame{
    NSNumber *savedWindowLevel = [[SettingManager sharedManager] windowLevel];
    NSUInteger windowLevel = NSFloatingWindowLevel;
    float menuBarHeight=[[[NSApplication sharedApplication] mainMenu] menuBarHeight];
    if (savedWindowLevel != nil) {
        switch (savedWindowLevel.intValue) {
            case 0:
                windowLevel = CGShieldingWindowLevel();
                menuBarHeight = 0;
                break;
            case 1:
                windowLevel = NSFloatingWindowLevel;
                break;
            case 2:
                windowLevel = kCGDesktopIconWindowLevel+1;
                break;
            default:
                break;
        }
    }
    [self.window setLevel:windowLevel];
	float totalWidth=[self.window.screen frame].size.width;
	float totalHeight=[self.window.screen frame].size.height-menuBarHeight;
	
	[[self window] setFrame:CGRectMake(0, 0, totalWidth, totalHeight) display:YES];
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        Status *s = [[Status alloc] init];
//        s.text = @"hello";
//        [self streamController:nil didReceivedStatus:s];
//    });
}

- (void)showWindow:(id)sender {
    [super showWindow:sender];
    [self resetFrame];
}

-(void)setSearchTerm:(NSString*)searchTerm{
    [StreamController shared].searchTerm = searchTerm;
}
#pragma mark stream delegate
-(void)streamController:(id)controller didReceivedStatus:(Status*)tweet {
    typeof(self) __weak _self = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![_self shouldShowStatus:tweet]) return;
        
        RainDropViewController *thisViewController=[[RainDropViewController alloc]initWithStatus:tweet];
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
        [rainDrops addObject:thisViewController];
    });
}

-(BOOL)shouldShowStatus:(Status*)status{
	if([shownStatuses containsObject:status]){
		return NO;
	}
	[shownStatuses addObject:status];
	return YES;
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
	[rainDrops removeObject:rainDrop];
    [shownStatuses removeObject:rainDrop.status];
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
