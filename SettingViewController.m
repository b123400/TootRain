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

@implementation SettingViewController

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
	
	overlapsMenuBarCheckBox.state=[[SettingManager sharedManager] overlapsMenuBar]?NSOnState:NSOffState;
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
}
#pragma mark tableview datasource+delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
	if(aTableView==accountsTableView){
        
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
		return thisAccount.username;
	}
	return nil;
}
#pragma mark Accounts
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
	if(tableView==accountsTableView){
		return 44;
	}
	return 0;
}

- (IBAction)authorizeButtonTapped:(id)sender {
    [[SettingManager sharedManager].accountStore requestAccessToAccountsWithType:[SettingManager sharedManager].accountType options:nil completion:^(BOOL granted, NSError *error) {
        if (granted) {
            [accountsTableView reloadData];
        } else {
            NSAlert *alert = [NSAlert alertWithError:error];
            [alert runModal];
        }
    }];
}


#pragma mark Appearance

- (IBAction)overlapsMenuCheckBoxChanged:(id)sender {
	BOOL enabled=[(NSButton*)sender state]==NSOnState;
	[[NSUserDefaults standardUserDefaults] setBool:enabled forKey:@"overlapsMenuBar"];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[(FloodWindowController*)[(FloodAppDelegate*)[NSApp delegate] windowController] resetFrame];
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
}
- (IBAction)textColorWellChanged:(id)sender {
	NSColorWell *well=sender;
	NSData *theData=[NSArchiver archivedDataWithRootObject:well.color];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"textColor"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
- (IBAction)shadowColorWellChanged:(id)sender {
	NSColorWell *well=sender;
	NSData *theData=[NSArchiver archivedDataWithRootObject:well.color];
	[[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"shadowColor"];
	[[NSUserDefaults standardUserDefaults] synchronize];
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
}

@end
