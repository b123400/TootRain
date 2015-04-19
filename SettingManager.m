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

- (BOOL)hideTweetAroundCursor {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideTweetAroundCursor"];
}

- (void)setHideTweetAroundCursor:(BOOL)hideTweetAroundCursor {
    [[NSUserDefaults standardUserDefaults] setBool:hideTweetAroundCursor forKey:@"hideTweetAroundCursor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)showProfileImage {
    NSNumber *show = [[NSUserDefaults standardUserDefaults] objectForKey:@"showProfileImage"];
    if (show == nil) {
        return YES;
    }
    return [show boolValue];
}

- (void)setShowProfileImage:(BOOL)showProfileImage {
    [[NSUserDefaults standardUserDefaults] setBool:showProfileImage forKey:@"showProfileImage"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (BOOL)removeURL {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"removeURL"];
}

- (void)setRemoveURL:(BOOL)removeURL {
    [[NSUserDefaults standardUserDefaults] setBool:removeURL forKey:@"removeURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (BOOL)underlineTweetsWithURL {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"underlineTweetsWithURL"];
}

- (void)setUnderlineTweetsWithURL:(BOOL)underlineTweetsWithURL {
    [[NSUserDefaults standardUserDefaults] setBool:underlineTweetsWithURL forKey:@"underlineTweetsWithURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (float)opacity {
    NSNumber *opacity=[[NSUserDefaults standardUserDefaults]objectForKey:@"opacity"];
    if(!opacity){
        //opacity isn't set
        return 1;
    }
    return [opacity floatValue];
}

- (void)setOpacity:(float)opacity {
    [[NSUserDefaults standardUserDefaults] setFloat:opacity forKey:@"opacity"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

#if TARGET_OS_IPHONE

- (UIColor*)textColor {
    NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"textColor"];
    if (theData == nil)return [UIColor whiteColor];
    return (UIColor*)[NSKeyedUnarchiver unarchiveObjectWithData:theData] ?: [UIColor whiteColor];
}

- (void)setTextColor:(UIColor *)color {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:color] forKey:@"textColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (UIColor*)shadowColor {
    NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"shadowColor"];
    if (theData == nil)return [UIColor blackColor];
    return (UIColor*)[NSKeyedUnarchiver unarchiveObjectWithData:theData] ?: [UIColor blackColor];
}
- (void)setShadowColor:(UIColor *)color {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:color] forKey:@"shadowColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (UIColor*)hoverBackgroundColor {
    NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"selectedBackgroundColor"];
    if (theData == nil)return [UIColor whiteColor];
    return (UIColor *)[NSKeyedUnarchiver unarchiveObjectWithData:theData] ?: [UIColor whiteColor];
}
- (void)setHoverBackgroundColor:(UIColor *)color {
    [[NSUserDefaults standardUserDefaults] setObject:[NSKeyedArchiver archivedDataWithRootObject:color] forKey:@"selectedBackgroundColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (UIFont*)font {
    return [UIFont fontWithName:self.fontName size:self.fontSize];
}

- (void)setFont:(UIFont*)font {
    [self setFontName:[font fontName]];
    [self setFontSize:[font pointSize]];
}

- (NSString*)fontName {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"fontName"] ?: @"Arial";
}

- (void)setFontName:(NSString *)fontName {
    [[NSUserDefaults standardUserDefaults] setObject:fontName forKey:@"fontName"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (float)fontSize {
    NSNumber *size = [[NSUserDefaults standardUserDefaults] objectForKey:@"fontSize"];
    if (!size) {
        return 36.0;
    }
    return [size floatValue];
}
- (void)setFontSize:(float)fontSize {
    [[NSUserDefaults standardUserDefaults] setFloat:fontSize forKey:@"fontSize"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

#elif TARGET_OS_MAC

- (NSNumber*)windowLevel {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"windowLevel"];
}

- (void)setWindowLevel:(NSNumber*)windowLevel {
    [[NSUserDefaults standardUserDefaults] setObject:windowLevel forKey:@"windowLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWindowLevelChanged object:nil];
}

- (NSColor*)textColor{
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"textColor"];
	if (theData == nil)return [NSColor whiteColor];
	return (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
}

- (void)setTextColor:(NSColor*)color {
    NSData *theData=[NSArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"textColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (NSColor*)shadowColor{
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"shadowColor"];
	if (theData == nil)return [NSColor blackColor];
	return (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
}

- (void)setShadowColor:(NSColor*)color {
    NSData *theData=[NSArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"shadowColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (NSColor*) hoverBackgroundColor {
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"hoverBackgroundColor"];
	if (theData == nil)return [NSColor whiteColor];
	return (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
}

- (void)setHoverBackgroundColor:(NSColor*)color {
    NSData *theData=[NSArchiver archivedDataWithRootObject:color];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"hoverBackgroundColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSFont*)font{
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"font"];
	if (theData == nil)return [NSFont fontWithName:@"Arial" size:36];
	return (NSFont *)[NSUnarchiver unarchiveObjectWithData:theData];
}

- (void)setFont:(NSFont*)font {
    NSData *theData=[NSArchiver archivedDataWithRootObject:font];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"font"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

#endif

@end
