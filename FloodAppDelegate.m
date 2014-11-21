//
//  SmarkinAppDelegate.m
//  Smarkin
//
//  Created by b123400 on 27/04/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "FloodAppDelegate.h"
#import "SettingManager.h"
#import <Crashlytics/Crashlytics.h>

@implementation FloodAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self newWindow:self];
    [Crashlytics startWithAPIKey:@"be3de76eb1918a93b4d68a8e87b983750d738aed"];
}
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename{
	
	return NO;
}
-(IBAction)newWindow:(id)sender{
	if(![[SettingManager sharedManager] selectedAccount]){
		[[SettingViewController sharedPrefsWindowController] showWindow:self];
	}
    if(!windowController){
        windowController=[[FloodWindowController alloc]init];
    }
    [windowController showWindow:self];
    
    [[NSUserNotificationCenter defaultUserNotificationCenter] setDelegate:self];
}
-(IBAction)openSettingWindow:(id)sender{
	[[SettingViewController sharedPrefsWindowController] showWindow:self];
}

- (IBAction)openSearchWindow:(id)sender {
	if(!searchController){
		searchController=[[SearchWindowController alloc]init];
		searchController.delegate=self;
	}
	[searchController showWindow:self];
}
-(void)searchTermChangedTo:(NSString *)searchTerm{
	[windowController setSearchTerm:searchTerm];
}
-(FloodWindowController*)windowController{
	return windowController;
}

- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification{
    return YES;
}

@end
