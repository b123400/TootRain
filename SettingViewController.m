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
	[self addView:accountsSettingView label:@"Accounts" image:[NSImage imageNamed:@"NSUser"]];
	[self addView:appearanceSettingView label:@"Appearance" image:[NSImage imageNamed:@"NSColorPanel"]];
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
            return [NSString stringWithFormat:@"%@ (Streaming)",thisAccount.username];
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
    [[SettingManager sharedManager].accountStore requestAccessToAccountsWithType:[SettingManager sharedManager].accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [self updateAccountView];
            [[NSNotificationCenter defaultCenter] postNotificationName:ACAccountStoreDidChangeNotification object:nil];
        } else {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert setMessageText:[NSString stringWithFormat:@"Why dont you give me permission:(\n %@",[alert messageText]]];
            [alert runModal];
        }
    }];
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
    [[NSUserDefaults standardUserDefaults] setObject:@(index) forKey:@"windowLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWindowLevelChanged object:nil];
}
- (IBAction)hideTweetAroundCursorCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSOnState;
	[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"hideTweetAroundCursor"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)showProfileImageCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSOnState;
	[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"showProfileImage"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)removeURLCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSOnState;
	[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"removeURL"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}
- (IBAction)underlineTweetsWithURLCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSOnState;
	[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"underlineTweetsWithURL"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)opacitySliderChanged:(id)sender {
	NSSlider* slider=sender;
	[[NSUserDefaults standardUserDefaults] setFloat:slider.floatValue forKey:@"opacity"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}
- (IBAction)textColorWellChanged:(id)sender {
	NSColorWell *well=sender;
	NSData *theData=[NSArchiver archivedDataWithRootObject:well.color];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"textColor"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}
- (IBAction)shadowColorWellChanged:(id)sender {
	NSColorWell *well=sender;
	NSData *theData=[NSArchiver archivedDataWithRootObject:well.color];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"shadowColor"];
	[[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}
- (IBAction)hoverBackgroundColor:(id)sender {
	NSColorWell *well=sender;
	NSData *theData=[NSArchiver archivedDataWithRootObject:well.color];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"hoverBackgroundColor"];
	[[NSUserDefaults standardUserDefaults] synchronize];
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
	NSData *theData=[NSArchiver archivedDataWithRootObject:theFont];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"font"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[fontLabel setStringValue:[NSString stringWithFormat:@"Font: %@ %.0f",[theFont displayName],[theFont pointSize]]];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

@end
