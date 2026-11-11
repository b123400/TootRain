//
//  SmarkinAppDelegate.m
//  Smarkin
//
//  Created by b123400 on 27/04/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "FloodAppDelegate.h"
#import "SettingManager.h"
#import "ShowStatusIntentHandler.h"
#import "History Window/HistoryWindowController.h"
#import "TootRain-Swift.h"

@interface FloodAppDelegate () <NSMenuDelegate>
@property (nonatomic, strong) NSTimer *iconAnimationTimer;
@property (nonatomic, assign) int pendingAnimationCount;
@end

@implementation FloodAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self newWindow:self];
    NSImage *icon = [NSImage imageNamed:[[SettingManager sharedManager] customIcon]];
    [[NSApplication sharedApplication] setApplicationIconImage:icon];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(iconAnimation)
                                                 name:kRainDropAppearedNotification
                                               object:nil];
    
    [NSApp unhide:self];

    [[TootRainEnterpriseClient shared] applicationDidFinishLaunching];
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename{
	return NO;
}

// Steps 0-16: the cloud drifts up and fades out. Steps 17-25: a new one puffs out of the trunk. Step 0 is the resting icon.
- (NSImage *)iconAtAnimationStep:(int)step {
    BOOL leaving = step <= 16;
    CGFloat progress = leaving ? step / 16.0 : (step - 16) / 9.0;
    CGFloat scale = leaving ? 1 + 0.1 * progress : 0.3 + 0.7 * progress;
    CGFloat alpha = leaving ? 1 - progress * progress : progress;  // squared: still visible once it is past the icon's edge
    CGFloat rise = leaving ? 40 * progress : 0;  // ends above the artwork, inside Cloudless's transparent margin
    return [NSImage imageWithSize:NSMakeSize(256, 256) flipped:NO drawingHandler:^BOOL(NSRect rect) {
        [[NSImage imageNamed:@"Cloudless"] drawInRect:rect];
        // Cloudless has the transparent margin the Dock expects (artwork is 206pt, inset 25pt); the cloud's numbers below are in full-bleed 256pt artwork coordinates.
        NSAffineTransform *artwork = [NSAffineTransform transform];
        [artwork translateXBy:25 yBy:25];
        [artwork scaleBy:206.0 / 256];
        [artwork concat];
        // Scaled around the cloud's tail at (33, 172), where it leaves the trunk; the offsets are the tail's position inside Cloud.png.
        NSRect cloud = NSMakeRect(33 - 7.5 * scale, 172 + rise - 8 * scale, 99 * scale, 71 * scale);
        [[NSImage imageNamed:@"Cloud"] drawInRect:cloud fromRect:NSZeroRect operation:NSCompositingOperationSourceOver fraction:alpha];
        return YES;
    }];
}

- (void)iconAnimation {
    NSString *customIcon = [[SettingManager sharedManager] customIcon];
    if (customIcon) {
        [self.iconAnimationTimer invalidate];
        self.iconAnimationTimer = nil;
        self.pendingAnimationCount = 0;
        return;
    }
    if (!self.iconAnimationTimer) {
        __block int iconIndex = 0;
        NSTimeInterval interval = MAX(0.01, 0.1 / (self.pendingAnimationCount + 1));
        self.pendingAnimationCount = MAX(0, self.pendingAnimationCount - 1);
        self.iconAnimationTimer = [NSTimer scheduledTimerWithTimeInterval:interval repeats:YES block:^(NSTimer * _Nonnull timer) {
            if (iconIndex > 25) {
                [self.iconAnimationTimer invalidate];
                self.iconAnimationTimer = nil;
                [[NSApplication sharedApplication] setApplicationIconImage:[self iconAtAnimationStep:0]];
                if (self.pendingAnimationCount) {
                    [self iconAnimation];
                }
                return;
            }
            [[NSApplication sharedApplication] setApplicationIconImage:[self iconAtAnimationStep:iconIndex]];
            iconIndex++;
        }];
    } else {
        self.pendingAnimationCount++;
    }
}

- (id)application:(NSApplication *)application handlerForIntent:(INIntent *)intent API_AVAILABLE(macos(11.0)){
    return [[ShowStatusIntentHandler alloc] init];
}

-(IBAction)newWindow:(id)sender{
    if (![[SettingManager sharedManager] streamingAccounts].count) {
		[[SettingViewController sharedPrefsWindowController] showWindow:self];
	}
    if (!windowController) {
        windowController=[[FloodWindowController alloc]init];
    }
    [windowController showWindow:self];
}

-(IBAction)openSettingWindow:(id)sender{
	[[SettingViewController sharedPrefsWindowController] showWindow:self];
}

-(FloodWindowController*)windowController{
	return windowController;
}

- (IBAction)openHistoryWindow:(id)sender {
    [[HistoryWindowController shared] showWindow:self];
}

- (void)menuNeedsUpdate:(NSMenu *)menu {
    [menu removeAllItems];
    NSArray *accounts = [[SettingManager sharedManager] accounts];
    if (!accounts.count) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:NSLocalizedString(@"No account available", @"Menubar")
                                                      action:nil
                                               keyEquivalent:@""];
        item.enabled = NO;
        [menu addItem:item];
        return;
    }
    for (Account *account in accounts) {
        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:account.shortDisplayName
                                                      action:@selector(connectionItemClicked:)
                                               keyEquivalent:@""];
        item.target = self;
        item.identifier = account.identifier;
        item.image = account.serviceImage;
        item.state = [[SettingManager sharedManager] isAccountStreaming:account] ? NSControlStateValueOn : NSControlStateValueOff;
        [menu addItem:item];
    }
}

- (void)connectionItemClicked:(NSMenuItem *)sender {
    Account *account = [[SettingManager sharedManager] accountWithIdentifier:sender.identifier];
    [[SettingManager sharedManager] setStreamingState:![[SettingManager sharedManager] isAccountStreaming:account] forAccount:account];
}

@end
