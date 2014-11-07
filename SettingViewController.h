//
//  SettingViewController.h
//  Smarkin
//
//  Created by b123400 on 28/05/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import <Social/Social.h>
#import <Accounts/Accounts.h>

#define kRainDropAppearanceChangedNotification @"kRainDropAppearanceChangedNotification"

@interface SettingViewController : DBPrefsWindowController <NSTableViewDataSource,NSTableViewDelegate> {
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

@property (weak) IBOutlet NSScrollView *tableViewScrollView;

@property (strong) IBOutlet NSButton *authorizeButton;
@property (strong) IBOutlet NSView *authorizeView;
@property (strong) IBOutlet NSView *emptyAccountView;

@end
