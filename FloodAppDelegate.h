//
//  SmarkinAppDelegate.h
//  Smarkin
//
//  Created by b123400 on 27/04/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import "SettingViewController.h"
#import "FloodWindowController.h"
#import "SearchWindowController.h"

@interface FloodAppDelegate : NSObject <NSApplicationDelegate,SearchWindowControllerDelegate> {
	FloodWindowController *windowController;
	SettingViewController *settingController;
	SearchWindowController *searchController;
}

- (FloodWindowController*)windowController;

-(IBAction)newWindow:(id)sender;
-(IBAction)openSettingWindow:(id)sender;
- (IBAction)openSearchWindow:(id)sender;

@end
