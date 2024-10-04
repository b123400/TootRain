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
#import "TransparentView.h"
#import "NewUpdateStatus.h"

@interface FloodWindowController ()
@property (weak) IBOutlet TransparentView *backgroundView;

-(BOOL)shouldShowStatus:(Status*)status;

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
    
    [self checkForUpdate];
	
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
    CGRect screenFrame = self.window.screen.frame;
    float totalWidth = screenFrame.size.width;
    float totalHeight = screenFrame.size.height;
    switch (savedWindowLevel) {
        case WindowLevelAboveMenuBar:
            windowLevel = CGShieldingWindowLevel();
            break;
        case WindowLevelAboveAllWindows:
            windowLevel = NSFloatingWindowLevel;
            totalHeight -= menuBarHeight;
            break;
        case WindowLevelAboveAllWindowsNoDock:
            windowLevel = NSFloatingWindowLevel;
            screenFrame = NSIntersectionRect(screenFrame, self.window.screen.visibleFrame);
            totalHeight = screenFrame.size.height;
            break;
        case WindowLevelAboveDesktop:
            windowLevel = kCGDesktopIconWindowLevel+1;
            break;
        default:
            break;
    }
    [self.window setLevel:windowLevel];
    
	
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
        frame.origin.y=[_self suitableYForStatusViewController:thisViewController];
        if (frame.origin.y < 0) {
            // out of screen, discard
            return;
        }
        thisViewController.view.frame=frame;
        [[[_self window] contentView]addSubview: [thisViewController view]];
        thisViewController.delegate=self;
        [self.rainDrops addObject:thisViewController];
        
        [[HistoryWindowController shared] addStatus:status];
        [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearedNotification object:thisViewController];
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
-(float)ySuggestionForStatusViewController:(RainDropViewController*)controller atY:(float)thisY flipped:(BOOL)flipped {
	float startY = thisY;
	for(RainDropViewController *thisController in self.rainDrops){
		if((thisController.view.frame.origin.y <= thisY &&
			thisController.view.frame.origin.y + thisController.view.frame.size.height >= thisY) ||
		   (thisController.view.frame.origin.y <= thisY + controller.view.frame.size.height &&
			thisController.view.frame.origin.y >= thisY)){
			//y position overlap
			if([thisController willCollideWithRainDrop:controller]){
                if (!flipped) {
                    startY = thisController.view.frame.origin.y - controller.view.frame.size.height - 1;
                } else {
                    startY += thisController.view.frame.size.height + 1;
                }
			}
		}
	}
	return startY;
}
-(float)suitableYForStatusViewController:(RainDropViewController*)controller{
    BOOL isFlipped = [[SettingManager sharedManager] flipUpDown];
    float possibleY = isFlipped ? 0 : self.window.frame.size.height - controller.view.frame.size.height;
	while((!isFlipped && possibleY > 0) || (isFlipped && possibleY + controller.view.frame.size.height < self.window.frame.size.height)) {
		float suggestion=[self ySuggestionForStatusViewController:controller atY:possibleY flipped:isFlipped];
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
	CGPoint point = [self.window.contentView convertPoint:NSPointToCGPoint(mouseLoc) fromView:nil];
    [self.backgroundView setCursorLocation:point];
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
    CGPoint point = [self.window.contentView convertPoint:NSPointToCGPoint(mouseLoc) fromView:nil];
    for (RainDropViewController *thisController in self.rainDrops) {
        CGRect rect = [thisController visibleFrame];
        if (CGRectContainsPoint(rect, point)) {
            [thisController viewDidClicked:self];
            return;
        }
    }
    [super mouseUp:event];
}

#pragma - Check for update
- (void)checkForUpdate {
    NSURLSessionDataTask *task = [[NSURLSession sharedSession] dataTaskWithURL:[NSURL URLWithString:@"https://api.github.com/repos/b123400/TootRain/tags"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSArray *tags = [NSJSONSerialization JSONObjectWithData:data options:nil error:nil];
        if (![tags isKindOfClass:[NSArray class]]) return;
        NSString *tagName = [tags firstObject][@"name"];
        if (![tagName hasPrefix:@"tootrain-"]) return;
        NSString *latestVersion = [tagName stringByReplacingOccurrencesOfString:@"tootrain-" withString:@""];
        NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
        NSString *appVersion = [infoDict objectForKey:@"CFBundleShortVersionString"];
        if ([latestVersion compare:appVersion options:NSNumericSearch] == NSOrderedDescending) {
            NewUpdateStatus *status = [[NewUpdateStatus alloc] init];
            status.text = NSLocalizedString(@"New version of TootRain available!", @"");
            [self streamController:[StreamController shared] didReceivedStatus:status];
        }
    }];
    [task resume];
}
@end
