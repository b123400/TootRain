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
    
    self.accountStore = [[ACAccountStore alloc] init];
    self.accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    return self;
}



#pragma mark - settings

- (ACAccount *)selectedAccount {
    NSArray *accounts = self.accounts;
    if (accounts.count == 0) {
        return nil;
    }
    return [self.accounts objectAtIndex:0];
}

- (NSArray*)accounts {
    if (!self.accountType.accessGranted) {
        return 0;
    }
    return [self.accountStore accountsWithAccountType:self.accountType];
}

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
