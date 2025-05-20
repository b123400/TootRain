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
// Need this for menu bar update item
#ifdef STANDALONE
#import "Sparkle/SPUStandardUpdaterController.h"
#endif

@interface FloodAppDelegate : NSObject <NSApplicationDelegate> {
	FloodWindowController *windowController;
	SettingViewController *settingController;
}

#ifdef STANDALONE
@property (weak) IBOutlet SPUStandardUpdaterController *updaterController;
#endif

- (FloodWindowController*)windowController;

-(IBAction)newWindow:(id)sender;
-(IBAction)openSettingWindow:(id)sender;

@end
