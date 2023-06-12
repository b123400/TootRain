//
//  SettingManager.m
//  Canvas
//
//  Created by b123400 Chan on 4/2/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "SettingManager.h"
#import "NSFileManager+DirectoryLocations.h"
#import "BRMastodonAccount.h"
#import "BRSlackAccount.h"
#import "BRMisskeyAccount.h"

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
    [accounts addObjectsFromArray:[BRMastodonAccount allAccounts]];
    [accounts addObjectsFromArray:[BRSlackAccount allAccounts]];
    [accounts addObjectsFromArray:[BRMisskeyAccount allAccounts]];
    self.accounts = accounts;
}

- (Account *)accountWithIdentifier:(NSString *)identifier {
    for (int i = 0; i < self.accounts.count; i++) {
        Account *thisAccount = [self.accounts objectAtIndex:i];
        if ([thisAccount.identifier isEqualToString:identifier]) {
            return thisAccount;
        }
    }
    return nil;
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

- (BOOL)animateGif {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"animateGif"];
    if (!num) {
        return YES;
    }
    return [num boolValue];
}

- (void)setAnimateGif:(BOOL)animateGif {
    [[NSUserDefaults standardUserDefaults] setBool:animateGif forKey:@"animateGif"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (float)speed {
    NSNumber *num = [[NSUserDefaults standardUserDefaults] objectForKey:@"speed"];
    if (!num) {
        return 15;
    }
    return [num floatValue];
}

- (void)setSpeed:(float)speed {
    [[NSUserDefaults standardUserDefaults] setFloat:speed forKey:@"speed"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropSpeedChanegdNotification object:nil];
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
    return [self settingDataWithKey:@"textColor" ofClass:[NSColor class] defaultValue:[NSColor whiteColor]];
}

- (void)setTextColor:(NSColor*)color {
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:NO error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"textColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (NSColor*)shadowColor{
    return [self settingDataWithKey:@"shadowColor" ofClass:[NSColor class] defaultValue:[NSColor blackColor]];
}

- (void)setShadowColor:(NSColor*)color {
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:NO error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"shadowColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (NSColor*) hoverBackgroundColor {
    return [self settingDataWithKey:@"hoverBackgroundColor" ofClass:[NSColor class] defaultValue:[NSColor whiteColor]];
}

- (void)setHoverBackgroundColor:(NSColor*)color {
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:color requiringSecureCoding:NO error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"hoverBackgroundColor"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSFont*)font{
    return [self settingDataWithKey:@"font" ofClass:[NSFont class] defaultValue:[NSFont fontWithName:@"Arial" size:36]];
}

- (void)setFont:(NSFont*)font {
    NSData *theData = [NSKeyedArchiver archivedDataWithRootObject:font requiringSecureCoding:NO error:nil];
    [[NSUserDefaults standardUserDefaults] setObject:theData forKey:@"font"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSNotificationCenter defaultCenter] postNotificationName:kRainDropAppearanceChangedNotification object:nil];
}

- (NSString *)customIcon {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"customIcon"];
}

- (void)setCustomIcon:(NSString *)customIcon {
    [[NSUserDefaults standardUserDefaults] setObject:customIcon forKey:@"customIcon"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSApplication sharedApplication] setApplicationIconImage:[NSImage imageNamed:customIcon]];
}

- (id)settingDataWithKey:(NSString *)key ofClass:(Class)class defaultValue:(id)defaultValue {
    NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:key];
    if (theData == nil)return defaultValue;
    id keyedResult = [NSKeyedUnarchiver unarchivedObjectOfClass:class
                                                       fromData:theData
                                                          error:nil];
    if (keyedResult) return keyedResult;
    id legacyResult = [NSUnarchiver unarchiveObjectWithData:theData];
    if ([legacyResult isKindOfClass:class]) {
        NSData *newData = [NSKeyedArchiver archivedDataWithRootObject:legacyResult requiringSecureCoding:NO error:nil];
        [[NSUserDefaults standardUserDefaults] setObject:newData forKey:key];
        [[NSUserDefaults standardUserDefaults] synchronize];
        return legacyResult;
    }
    return defaultValue;
}

#endif

@end
