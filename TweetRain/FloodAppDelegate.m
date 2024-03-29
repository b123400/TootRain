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
// Need this for menu bar update item
#ifdef STANDALONE
#import "Sparkle/SPUStandardUpdaterController.h"
#endif

@implementation FloodAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self newWindow:self];
    NSImage *icon = [NSImage imageNamed:[[SettingManager sharedManager] customIcon]];
    [[NSApplication sharedApplication] setApplicationIconImage:icon];
    [NSApp unhide:self];
}
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename{
	return NO;
}

- (id)application:(NSApplication *)application handlerForIntent:(INIntent *)intent API_AVAILABLE(macos(11.0)){
    return [[ShowStatusIntentHandler alloc] init];
}

-(IBAction)newWindow:(id)sender{
	if(![[SettingManager sharedManager] selectedAccount]){
		[[SettingViewController sharedPrefsWindowController] showWindow:self];
	}
    if(!windowController){
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

@end
