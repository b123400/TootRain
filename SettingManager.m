//
//  SettingManager.m
//  Canvas
//
//  Created by b123400 Chan on 4/2/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "SettingManager.h"
#import "NSFileManager+DirectoryLocations.h"
#import "MastodonAccount.h"
#import "SlackAccount.h"
#import "BRMastodonAccount.h"
#import "BRSlackAccount.h"

@interface SettingManager ()

@property (nonatomic, strong) NSArray<Account*> *accounts;

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
    if (self = [super init]) {
        [self reloadAccounts];
    }
    return self;
}

#pragma mark accounts

- (Account *)selectedAccount {
    NSArray *accounts = self.accounts;
    if (accounts.count == 0) {
        return nil;
    }
    NSString *selectedAccountId = [[NSUserDefaults standardUserDefaults] stringForKey:@"selectedAccountId"];
    for (Account *thisAccount in accounts) {
        if ([thisAccount.identifier isEqualToString:selectedAccountId]) {
            return thisAccount;
        }
    }
    return nil;
}

- (void)setSelectedAccount:(Account*)account {
    if (account) {
        [[NSUserDefaults standardUserDefaults] setObject:account.identifier forKey:@"selectedAccountId"];
    } else {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"selectedAccountId"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kSelectedAccountChanged object:nil];
}

- (void)reloadAccounts {
    NSMutableArray *accounts = [NSMutableArray array];
    for (BRMastodonAccount *acc in [BRMastodonAccount allAccounts]) {
        [accounts addObject:[[MastodonAccount alloc] initWithMastodonAccount:acc]];
    }
    for (BRSlackAccount *acc in [BRSlackAccount allAccounts]) {
        [accounts addObject:[[SlackAccount alloc] initWithSlackAccount:acc]];
    }
    self.accounts = accounts;
}

#pragma mark - settings


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

- (BOOL)removeLinks {
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"removeLinks"];
}

- (void)setRemoveLinks:(BOOL)removeURL {
    [[NSUserDefaults standardUserDefaults] setBool:removeURL forKey:@"removeLinks"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (BOOL)truncateStatus {
    NSNumber *obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"truncateStatus"];
    if (!obj) {
        return YES;
    }
    return [obj boolValue];
}

- (void)setTruncateStatus:(BOOL)underlineTweetsWithURL {
    [[NSUserDefaults standardUserDefaults] setBool:underlineTweetsWithURL forKey:@"truncateStatus"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSInteger)truncateStatusLength {
    NSNumber *obj = [[NSUserDefaults standardUserDefaults] objectForKey:@"truncateStatusLength"];
    if (!obj) {
        return 50;
    }
    return [obj integerValue];
}

- (void)setTruncateStatusLength:(NSInteger)truncateStatusLength {
    [[NSUserDefaults standardUserDefaults] setInteger:truncateStatusLength forKey:@"truncateStatusLength"];
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

- (BOOL)showShadow {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"showShadow"];
    if (!num) {
        return YES;
    }
    return [num boolValue];
}

- (void)setShowShadow:(BOOL)showShadow {
    [[NSUserDefaults standardUserDefaults] setBool:showShadow forKey:@"showShadow"];
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

- (WindowLevel)windowLevel {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"windowLevel"];
    if (!num) {
        return WindowLevelAboveAllWindows;
    }
    return [num unsignedIntegerValue];
}

- (void)setWindowLevel:(WindowLevel)windowLevel {
    [[NSUserDefaults standardUserDefaults] setObject:@(windowLevel) forKey:@"windowLevel"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kWindowLevelChanged object:nil];
}

- (CursorBehaviour)cursorBehaviour {
    return [[[NSUserDefaults standardUserDefaults] objectForKey:@"cursorBehaviour"] unsignedIntegerValue];
}

- (void)setCursorBehaviour:(CursorBehaviour)cursorBehaviour {
    [[NSUserDefaults standardUserDefaults] setObject:@(cursorBehaviour) forKey:@"cursorBehaviour"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kCursorBehaviourChanged object:nil];
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
