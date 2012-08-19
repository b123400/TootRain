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

@interface FloodAppDelegate : NSObject <NSApplicationDelegate> {
	FloodWindowController *windowController;
	SettingViewController *settingController;
}

-(FloodWindowController*)windowController;

-(IBAction)newWindow:(id)sender;
-(IBAction)openSettingWindow:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
