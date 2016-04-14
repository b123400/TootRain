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
#import <Fabric/Fabric.h>

@implementation FloodAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self newWindow:self];
    [[NSUserDefaults standardUserDefaults] registerDefaults:@{
                                                              @"NSApplicationCrashOnExceptions": @YES
                                                              }];
    [Fabric with:@[[Crashlytics class]]];
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
