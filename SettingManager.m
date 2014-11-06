//
//  SettingManager.m
//  Canvas
//
//  Created by b123400 Chan on 4/2/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "SettingManager.h"
#import "NSFileManager+DirectoryLocations.h"

@interface SettingManager ()

- (void)accountStoreDidChanged:(NSNotification*)notification;

@end

@implementation SettingManager
static NSMutableArray *savedAccounts=nil;

+(SettingManager*)sharedManager{
	static SettingManager *manager=nil;
	if(!manager){
		manager=[[SettingManager alloc]init];
	}
	return manager;
}

-(id)init{
    self = [super init];
    
    if (self) {
        self.accountStore = [[ACAccountStore alloc] init];
        self.accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accountStoreDidChanged:) name:ACAccountStoreDidChangeNotification object:nil];
    }
    return self;
}



#pragma mark accounts

- (ACAccount *)selectedAccount {
    NSArray *accounts = self.accounts;
    if (accounts.count == 0) {
        return nil;
    }
    NSString *selectedAccountID = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedAccountID"];
    for (ACAccount *thisAccount in accounts) {
        if ([thisAccount.identifier isEqualToString:selectedAccountID]) {
            return thisAccount;
        }
    }
    return [self.accounts objectAtIndex:0];
}

- (void)setSelectedAccount:(ACAccount*)account {
    for (ACAccount *thatAccount in self.accounts) {
        if ([[account identifier] isEqualToString:[thatAccount identifier]]) {
            [[NSUserDefaults standardUserDefaults] setObject:account.identifier forKey:@"selectedAccountID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return;
        }
    }
}

- (NSArray*)accounts {
    if (!self.accountType.accessGranted) {
        return 0;
    }
    NSArray *accounts = [self.accountStore accountsWithAccountType:self.accountType];
    return accounts;
}

- (void)accountStoreDidChanged:(NSNotification*)notification {
    
}

#pragma mark - settings

-(BOOL)overlapsMenuBar{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"overlapsMenuBar"];
}
-(BOOL)hideTweetAroundCursor{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideTweetAroundCursor"];
}
-(BOOL)showProfileImage{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"showProfileImage"];
}
-(BOOL)removeURL{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"removeURL"];
}
-(BOOL)underlineTweetsWithURL{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"underlineTweetsWithURL"];
}
-(float)opacity{
	float opacity=[[NSUserDefaults standardUserDefaults]floatForKey:@"opacity"];
	if(opacity==0){
		//opacity isn't set
		opacity=1;
	}
	return opacity;
}
-(NSColor*)textColor{
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"textColor"];
	if (theData == nil)return [NSColor whiteColor];
	return (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
}
-(NSColor*)shadowColor{
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"shadowColor"];
	if (theData == nil)return [NSColor blackColor];
	return (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
}
-(NSColor*)hoverBackgroundColor{
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"hoverBackgroundColor"];
	if (theData == nil)return [NSColor whiteColor];
	return (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
}
-(NSFont*)font{
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"font"];
	if (theData == nil)return [NSFont fontWithName:@"Arial" size:36];
	return (NSFont *)[NSUnarchiver unarchiveObjectWithData:theData];
}
@end
