//
//  SettingViewController.m
//  Smarkin
//
//  Created by b123400 on 28/05/2011.
//  Copyright 2011 home. All rights reserved.
//
#import <MKAbeFook/MKAbeFook.h>
#import "SettingViewController.h"
#import "FloodAppDelegate.h"
#import "SettingManager.h"

@implementation SettingViewController

-(void)setupToolbar{
	[self addView:accountsSettingView label:@"Accounts" image:[NSImage imageNamed:@"NSUserAccounts"]];
	//[self addView:themesSettingView label:@"Themes"];
}

+ (NSString *)nibName{
	return @"SettingViewController";
}
- (void)windowDidLoad{
	[super windowDidLoad];
	[[accountsTableView layer] setCornerRadius:30];
}
#pragma mark tableview datasource+delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
	if(aTableView==accountsTableView){
		return [[[SettingManager sharedManager] accounts] count];
	}
	return 0;
}
- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
	int columnIndex=[[aTableView tableColumns] indexOfObject:aTableColumn];
	if(aTableView==accountsTableView){
		switch (columnIndex) {
			case 0:
				return [NSImage imageNamed:@"close-active.tiff"];
				break;
			case 1:
			{
				User *thisAccount=[[[SettingManager sharedManager] accounts] objectAtIndex:rowIndex];
				return thisAccount.username;
				break;
			}
			case 2:
				return [NSImage imageNamed:@"close-active.tiff"];
				break;
			default:
				break;
		}
	}
	return nil;
}
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
	NSTableView *targetTableView=aNotification.object;
	
}
#pragma mark Accounts
- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
	if(tableView==accountsTableView){
		return 44;
	}
	return 0;
}
-(IBAction)newAccountClicked:(id)sender{
	NSMenu *menu=[[NSMenu alloc]initWithTitle:@"title"];
	[menu addItemWithTitle:@"Twitter" action:@selector(newTwitterAccount) keyEquivalent:@""];
	[menu addItemWithTitle:@"Facebook" action:@selector(newFacebookAccount) keyEquivalent:@""];
	[NSMenu popUpContextMenu:menu withEvent:[NSApp currentEvent] forView:sender];
}

- (IBAction)deleteAccountClicked:(id)sender {
	int selectedIndex=[accountsTableView selectedRow];
	if(selectedIndex<0)return;
	User *selectedAccount=[[[SettingManager sharedManager]accounts] objectAtIndex:selectedIndex];
	[[SettingManager sharedManager] deleteAccount:selectedAccount];
	[accountsTableView reloadData];
}
#pragma mark new twitter account
-(void)newTwitterAccount{
	NewTwitterAccountWindowController *twitterWindowController=[[NewTwitterAccountWindowController alloc]init];
	[twitterWindowController setDelegate:self];
	[NSApp	beginSheet:[twitterWindowController window] modalForWindow:[super window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
}
-(void)didCanceledAddingTwitterAccount:(NewTwitterAccountWindowController*)sender{
	[[sender window] orderOut:self];
	[NSApp endSheet:[sender window]];
	[sender release];
}
-(void)didAddedTwitterAccount:(User*)account sender:(id)sender{
	[[sender window] orderOut:self];
	[NSApp endSheet:[sender window]];
	[sender release];
	
	[[SettingManager sharedManager] addAccount:account];
	[accountsTableView reloadData];
	
	if([[[SettingManager sharedManager]accounts]count]==1){
		//this is the first account, probably the only account in flood.
		[(FloodAppDelegate*)[[NSApplication sharedApplication]delegate] newWindow:self];
	}
}
#pragma mark facebook
/*-(void)newFacebookAccount{
	MKFacebook *fbConnection = [MKFacebook facebookWithAPIKey:kFacebookOAuthConsumerKey delegate:self];
	if([fbConnection userLoggedIn]){
		NSAlert *alert = [[[NSAlert alloc] init] autorelease];
		[alert addButtonWithTitle:@"OK"];
		[alert setMessageText:@"Unfortunately, only one Facebook accounts at the same time."];
		//[alert setInformativeText:@"Message text goes here."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:[super window] modalDelegate:self didEndSelector:nil contextInfo:nil];
	}else{
		NSWindow *sheet=[fbConnection loginWithPermissions:[NSArray arrayWithObjects:@"read_stream",@"publish_stream",@"offline_access",nil] forSheet:YES];
		[NSApp beginSheet:sheet modalForWindow:[super window] modalDelegate:nil didEndSelector:nil contextInfo:nil];
	}
}*/
-(void)userLoginSuccessful
{
    NSLog(@"neat");
}
#pragma Themes

@end
