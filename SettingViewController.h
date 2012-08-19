//
//  SettingViewController.h
//  Smarkin
//
//  Created by b123400 on 28/05/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "NewTwitterAccountWindowController.h"

@interface SettingViewController : DBPrefsWindowController <NSTableViewDataSource,NSTableViewDelegate,NewTwitterAccountWindowControllerDelegate> {
	IBOutlet NSView *accountsSettingView;
	IBOutlet NSTableView *accountsTableView;
	
	IBOutlet NSView *appearanceSettingView;
	IBOutlet NSButton *overlapsMenuBarCheckBox;
	IBOutlet NSButtonCell *hideTweetAroundCursorCheckBox;
	IBOutlet NSButton *showProfileImageCheckBox;
	IBOutlet NSButton *removeURLCheckBox;
	IBOutlet NSButton *underlineTweetsWithURLCheckBox;
	IBOutlet NSSlider *opacitySlider;
	IBOutlet NSColorWell *textColorWell;
	IBOutlet NSColorWell *shadowColorWell;
	IBOutlet NSColorWell *hoverBackgroundColorWell;
	IBOutlet NSTextField *fontLabel;
}

-(void)newTwitterAccount;
-(IBAction)newAccountClicked:(id)sender;
- (IBAction)deleteAccountClicked:(id)sender;

@end
