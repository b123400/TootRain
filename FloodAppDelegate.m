//
//  SmarkinAppDelegate.m
//  Smarkin
//
//  Created by b123400 on 27/04/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "FloodAppDelegate.h"
#import "TwitterEngine.h"
#import "StreamingConsumer.h"
#import "StreamingDelegate.h"
#import "SettingManager.h"
#import "FloodWindowController.h"

@implementation FloodAppDelegate

@synthesize window;

+ (NSString *) UTIforFileExtension:(NSString *) extension {
    NSString * UTIString = (NSString *)UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, 
																			 (CFStringRef)extension, 
																			 NULL);
	
    return [UTIString autorelease];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
	[self newWindow:self];
}
- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename{
	
	return NO;
}
-(IBAction)newWindow:(id)sender{
	if([[[SettingManager sharedManager] accounts] count]<=0){
		[[SettingViewController sharedPrefsWindowController] showWindow:self];
		[(SettingViewController*)[SettingViewController sharedPrefsWindowController] newTwitterAccount];
		return;
	}else{
		[[[[FloodWindowController alloc]init]autorelease] showWindow:self];
	}
}
-(IBAction)openSettingWindow:(id)sender{
	[[SettingViewController sharedPrefsWindowController] showWindow:self];
}
-(void)dealloc{
	[super dealloc];
}

@end
