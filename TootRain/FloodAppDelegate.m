//
//  SmarkinAppDelegate.m
//  Smarkin
//
//  Created by b123400 on 27/04/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "FloodAppDelegate.h"
#import "SettingManager.h"
#import "BRSlackClient.h"
#import "ShowStatusIntentHandler.h"
#import "History Window/HistoryWindowController.h"

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
}

- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename{
	return NO;
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
                [[NSApplication sharedApplication] setApplicationIconImage:[NSImage imageNamed:@"AppIcon-animation00"]];
                if (self.pendingAnimationCount) {
                    [self iconAnimation];
                }
                return;
            }
            NSImage *image = [NSImage imageNamed:[NSString stringWithFormat:@"AppIcon-animation%02d", iconIndex]];
            [[NSApplication sharedApplication] setApplicationIconImage:image];
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
