//
//  SettingViewController.h
//  Smarkin
//
//  Created by b123400 on 28/05/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DBPrefsWindowController.h"
#import "SettingManager.h"
#import "BRSlackAccount.h"

@interface SettingViewController : DBPrefsWindowController <NSTableViewDataSource,NSTableViewDelegate> {
	IBOutlet NSView *accountsSettingView;
	IBOutlet NSTableView *accountsTableView;
    IBOutlet NSView *telemetryView;
    
	IBOutlet NSView *appearanceSettingView;
	IBOutlet NSButton *showProfileImageCheckBox;
	IBOutlet NSSlider *opacitySlider;
	IBOutlet NSColorWell *textColorWell;
    IBOutlet NSColorWell *shadowColorWell;
	IBOutlet NSColorWell *hoverBackgroundColorWell;
	IBOutlet NSTextField *fontLabel;
}

@property (weak) IBOutlet NSScrollView *tableViewScrollView;

@property (weak) IBOutlet NSTextField *instanceHostField;
@property (strong) IBOutlet NSButton *authorizeButton;
@property (strong) IBOutlet NSView *authorizeView;
@property (weak) IBOutlet NSButton *addAccountButton;
@property (weak) IBOutlet NSButton *deleteAccountButton;

@property (weak) IBOutlet NSPopUpButton *screenPopup;
@property (weak) IBOutlet NSPopUpButton *windowsLevelPopup;
@property (weak) IBOutlet NSPopUpButton *cursorBehaviourPopup;
@property (weak) IBOutlet NSButton *shadowCheckbox;
@property (weak) IBOutlet NSButton *truncateStatusCheckBox;
@property (weak) IBOutlet NSTextField *truncateStatusField;
@property (weak) IBOutlet NSStepper *truncateStatusStepper;
@property (weak) IBOutlet NSButton *removeLinksCheckBox;
@property (weak) IBOutlet NSButton *telemetryCheckbox;

- (void)addAccountWithHostName:(NSString *)hostName;
- (void)addAccountWithHostName:(NSString *)hostName updatingSlackAccount:(BRSlackAccount * _Nullable)slackAccount;

@end
