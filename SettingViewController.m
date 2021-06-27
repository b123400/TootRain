//
//  SettingViewController.m
//  Smarkin
//
//  Created by b123400 on 28/05/2011.
//  Copyright 2011 home. All rights reserved.
//
#import "SettingViewController.h"
#import "FloodAppDelegate.h"
#import "SettingManager.h"

@interface SettingViewController ()

- (void)updateAccountView;
- (void)accountStoreDidChanged:(NSNotification*)notification;

@end

@implementation SettingViewController

-(instancetype)initWithWindowNibName:(NSString *)windowNibName {
    self = [super initWithWindowNibName:windowNibName];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountStoreDidChanged:) name:ACAccountStoreDidChangeNotification object:nil];
    
    return self;
}

-(void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

-(void)setupToolbar{
	[self addView:accountsSettingView label:NSLocalizedString(@"Accounts", nil) image:[NSImage imageNamed:@"NSUser"] identifier:@"accounts"];
	[self addView:appearanceSettingView label:NSLocalizedString(@"Appearance",nil) image:[NSImage imageNamed:@"NSColorPanel"] identifier:@"appearance"];
}

+ (NSString *)nibName{
	return @"SettingViewController";
}

- (void)windowDidLoad{
	[super windowDidLoad];
	[[accountsTableView layer] setCornerRadius:30];
	
//	overlapsMenuBarCheckBox.state=[[SettingManager sharedManager] overlapsMenuBar]?NSOnState:NSOffState;
    NSNumber *savedWindowLevel = [[SettingManager sharedManager] windowLevel];
    if (!savedWindowLevel) {
        savedWindowLevel = @1;
    }
    [[self.windowsLevelPopup selectedItem] setState:0];
    [self.windowsLevelPopup selectItemAtIndex:savedWindowLevel.integerValue];
    [[self.windowsLevelPopup itemAtIndex:savedWindowLevel.integerValue] setState:1];
    
	hideTweetAroundCursorCheckBox.state=[[SettingManager sharedManager] hideTweetAroundCursor]?NSOnState:NSOffState;
	showProfileImageCheckBox.state=[[SettingManager sharedManager] showProfileImage]?NSOnState:NSOffState;
	removeURLCheckBox.state=[[SettingManager sharedManager] removeURL]?NSOnState:NSOffState;
	underlineTweetsWithURLCheckBox.state=[[SettingManager sharedManager] underlineTweetsWithURL]?NSOnState:NSOffState;
	opacitySlider.floatValue=[[SettingManager sharedManager]opacity];
	
	[textColorWell setColor:[[SettingManager sharedManager] textColor]];
	[shadowColorWell setColor:[[SettingManager sharedManager]shadowColor]];
	[hoverBackgroundColorWell setColor:[[SettingManager sharedManager]hoverBackgroundColor]];
	NSFont *theFont=[[SettingManager sharedManager]font];
	[fontLabel setStringValue:[NSString stringWithFormat:@"Font: %@ %.0f",[theFont displayName],[theFont pointSize]]];
    
    [self updateAccountView];
    
    // need to find using identifier becoz system api doesn't compare it well
    NSUInteger index = NSNotFound;
    NSArray *accounts = [[SettingManager sharedManager] accounts];
    ACAccount *selectedAccount = [[SettingManager sharedManager]selectedAccount];
    for (int i = 0; i<accounts.count; i++) {
        ACAccount *thisAccount = [accounts objectAtIndex:i];
        if ([thisAccount.identifier isEqualToString:selectedAccount.identifier]) {
            index = i;
            break;
        }
    }
    if (index != NSNotFound) {
        NSIndexSet *indexSet = [NSIndexSet indexSetWithIndex:index];
        [accountsTableView selectRowIndexes:indexSet byExtendingSelection:NO];
    }
    
    if (!accounts.count) {
        [self displayViewForIdentifier:@"accounts" animate:YES];
    }
}

#pragma mark tableview datasource+delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
	if (aTableView==accountsTableView) {
        
        return [SettingManager sharedManager].accounts.count;
	}
	return 0;
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
	if(aTableView==accountsTableView){
        if (![SettingManager sharedManager].accountType.accessGranted) {
            return 0;
        }
        NSArray *accounts = [SettingManager sharedManager].accounts;
        ACAccount *thisAccount=[accounts objectAtIndex:rowIndex];
        if ([thisAccount.identifier isEqualToString:[SettingManager sharedManager].selectedAccount.identifier]) {
            return [NSString stringWithFormat:NSLocalizedString(@"%@ (Streaming)",nil),thisAccount.username];
        }
		return thisAccount.username;
	}
	return nil;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    if(tableView==accountsTableView){
        return 44;
    }
    return 0;
}

#pragma mark Accounts

- (IBAction)authorizeButtonTapped:(id)sender {
//    [[SettingManager sharedManager].accountStore requestAccessToAccountsWithType:[SettingManager sharedManager].accountType options:nil completion:^(BOOL granted, NSError *error) {
//        if (granted) {
//            [self updateAccountView];
//            [[NSNotificationCenter defaultCenter] postNotificationName:ACAccountStoreDidChangeNotification object:nil];
//        } else {
//            NSAlert *alert = [NSAlert alertWithError:error];
//            [alert setMessageText:[NSString stringWithFormat:NSLocalizedString(@"Why dont you give me permission:(\n %@",nil),[alert messageText]]];
//            [alert runModal];
//        }
//    }];
}

- (void)updateAccountView {
    if ([SettingManager sharedManager].accountType.accessGranted) {
        [self.authorizeView removeFromSuperview];
        if ([SettingManager sharedManager].accounts.count != 0) {
            self.tableViewScrollView.hidden = NO;
            [self.emptyAccountView removeFromSuperview];
        } else {
            self.tableViewScrollView.hidden = YES;
            [accountsSettingView addSubview:self.emptyAccountView];
        }
    } else {
        [accountsSettingView addSubview:self.authorizeView];
        [self.emptyAccountView removeFromSuperview];
        self.tableViewScrollView.hidden = YES;
    }
    [accountsTableView reloadData];
}

- (IBAction)addAccountInstruction:(id)sender {
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://support.apple.com/kb/PH18993"]];
}

- (void)accountStoreDidChanged:(NSNotification*)notification {
    [self updateAccountView];
}

-(void)tableViewSelectionDidChange:(NSNotification *)notification {
    NSUInteger index = [accountsTableView selectedRow];
    ACAccount *selectedAccount = [[SettingManager sharedManager].accounts objectAtIndex:index];
    if ([[[SettingManager sharedManager] selectedAccount].identifier isEqualToString:selectedAccount.identifier]) {
        return;
    }
    if (selectedAccount) {
        [[SettingManager sharedManager] setSelectedAccount:selectedAccount];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:ACAccountStoreDidChangeNotification object:nil];
}

#pragma mark Appearance

- (IBAction)windowsLevelChanged:(id)sender {
    NSUInteger index = [self.windowsLevelPopup.itemArray indexOfObject:self.windowsLevelPopup.selectedItem];
    [[SettingManager sharedManager] setWindowLevel:@(index)];
}
- (IBAction)hideTweetAroundCursorCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSOnState;
    [[SettingManager sharedManager] setHideTweetAroundCursor:enabled];
}

- (IBAction)showProfileImageCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSOnState;
    [[SettingManager sharedManager] setShowProfileImage:enabled];
}
- (IBAction)removeURLCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSOnState;
    [[SettingManager sharedManager] setRemoveURL:enabled];
}
- (IBAction)underlineTweetsWithURLCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSOnState;
    [[SettingManager sharedManager] setUnderlineTweetsWithURL:enabled];
}

- (IBAction)opacitySliderChanged:(id)sender {
	NSSlider* slider=sender;
    [[SettingManager sharedManager] setOpacity:slider.floatValue];
}

- (IBAction)textColorWellChanged:(id)sender {
	NSColorWell *well=sender;
    [[SettingManager sharedManager] setTextColor:well.color];
}

- (IBAction)shadowColorWellChanged:(id)sender {
	NSColorWell *well=sender;
    [[SettingManager sharedManager] setShadowColor:well.color];
}

- (IBAction)hoverBackgroundColor:(id)sender {
	NSColorWell *well=sender;
    [[SettingManager sharedManager] setHoverBackgroundColor:well.color];
}
- (IBAction)chooseFontClicked:(id)sender {
	NSFontManager * fontManager = [NSFontManager sharedFontManager];
	[fontManager setTarget:self];
	[fontManager setSelectedFont:[[SettingManager sharedManager] font] isMultiple:NO];
	[fontManager orderFrontFontPanel:self];
}
- (void)changeFont:(id)sender{
	NSFontManager *manager=sender;
	NSFont *theFont=manager.selectedFont;
    [[SettingManager sharedManager] setFont:theFont];
	
    [fontLabel setStringValue:[NSString stringWithFormat:NSLocalizedString(@"Font: %@ %.0f",nil),[theFont displayName],[theFont pointSize]]];
}

@end
