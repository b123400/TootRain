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
#import "BorderHighlightButton.h"

@interface SettingViewController : DBPrefsWindowController <NSTableViewDataSource,NSTableViewDelegate> {
	IBOutlet NSView *accountsSettingView;
	IBOutlet NSTableView *accountsTableView;
    
	IBOutlet NSView *appearanceSettingView;
	IBOutlet NSButton *showProfileImageCheckBox;
	IBOutlet NSSlider *opacitySlider;
	IBOutlet NSColorWell *textColorWell;
    IBOutlet NSColorWell *shadowColorWell;
	IBOutlet NSColorWell *hoverBackgroundColorWell;
}

@property (weak) IBOutlet NSScrollView *tableViewScrollView;

@property (weak) IBOutlet NSButton *addAccountButton;
@property (weak) IBOutlet NSButton *deleteAccountButton;

@property (weak) IBOutlet NSPopUpButton *screenPopup;
@property (weak) IBOutlet NSPopUpButton *windowsLevelPopup;
@property (weak) IBOutlet NSPopUpButton *cursorBehaviourPopup;
@property (weak) IBOutlet NSButton *shadowCheckbox;
@property (weak) IBOutlet NSButton *truncateStatusCheckBox;
@property (weak) IBOutlet NSTextField *truncateStatusField;
@property (weak) IBOutlet NSStepper *truncateStatusStepper;
@property (weak) IBOutlet NSTextField *historyPreserveLimitField;
@property (weak) IBOutlet NSStepper *historyPreserveLimitStepper;
@property (weak) IBOutlet NSTextField *historyPreserveDurationLabel;
@property (weak) IBOutlet NSSlider *historyPreserveDurationSlider;
@property (weak) IBOutlet NSButton *removeLinksCheckBox;
@property (weak) IBOutlet NSButton *animateGifCheckbox;
@property (weak) IBOutlet NSButton *ignoreContentWarningsCheckbox;
@property (weak) IBOutlet NSButton *flipUpDownCheckbox;
@property (weak) IBOutlet NSButton *chooseFontButton;
@property (weak) IBOutlet NSSlider *speedSlider;


@property (weak) IBOutlet BorderHighlightButton *appIconDefaultButton;
@property (weak) IBOutlet BorderHighlightButton *appIconRIPButton;
@property (weak) IBOutlet BorderHighlightButton *appIconRIP2Button;

- (void)addAccountWithHostName:(NSString *)hostName
                   accountType:(SettingAccountType)accountType;

- (void)addAccountWithHostName:(NSString *)hostName
                   accountType:(SettingAccountType)accountType
          updatingSlackAccount:(BRSlackAccount * _Nullable)slackAccount;

@end
