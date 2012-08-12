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

#define kFacebookOAuthConsumerKey @"60bc92d0f31a3fef049f954b91377759"

@interface FloodAppDelegate : NSObject <NSApplicationDelegate> {
	IBOutlet id theWebview;
	SettingViewController *settingController;
}

-(IBAction)newWindow:(id)sender;
-(IBAction)openSettingWindow:(id)sender;

@property (assign) IBOutlet NSWindow *window;

@end
