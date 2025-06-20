//
//  SettingManager.h
//  Canvas
//
//  Created by b123400 Chan on 4/2/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "User.h"
#import "Account.h"

#define kRainDropAppearanceChangedNotification @"kRainDropAppearanceChangedNotification"
#define kWindowScreenChanged @"kWindowScreenChanged"
#define kWindowLevelChanged @"kWindowLevelChanged"
#define kCursorBehaviourChanged @"kCursorBehaviourChanged"
#define kRainDropSpeedChanegdNotification @"kRainDropSpeedChanegdNotification"
#define kFlipUpDownChangedNotification @"kFlipUpDownChangedNotification"
#define kStreamingAccountsChangedNotification @"kStreamingAccountsChangedNotification"

typedef enum : NSUInteger {
    CursorBehaviourPause = 0,
    CursorBehaviourHide = 1,
    CursorBehaviourClickThrough = 2,
    CursorBehaviourClipAround = 3,
} CursorBehaviour;

typedef enum : NSUInteger {
    WindowLevelAboveMenuBar = 0,
    WindowLevelAboveAllWindows = 1,
    WindowLevelAboveDesktop = 2,
    WindowLevelAboveAllWindowsNoDock = 3,
} WindowLevel;

typedef enum : NSUInteger {
    SettingAccountTypeMastodon,
    SettingAccountTypeSlack,
    SettingAccountTypeMisskey,
    SettingAccountTypeIrc,
} SettingAccountType;

@interface SettingManager : NSObject{
    
}

@property (nonatomic) BOOL showProfileImage;
@property (nonatomic) BOOL removeLinks;
@property (nonatomic) BOOL truncateStatus;
@property (nonatomic) NSInteger truncateStatusLength;
@property (nonatomic) float opacity;
@property (nonatomic) BOOL showShadow;
@property (nonatomic) BOOL animateGif;
@property (nonatomic) float speed;
@property (nonatomic) BOOL ignoreContentWarnings;
@property (nonatomic) NSInteger historyPreserveLimit;
@property (nonatomic) NSTimeInterval historyPreserveDuration;
@property (nonatomic) BOOL flipUpDown;

#if TARGET_OS_IPHONE

@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *shadowColor;
@property (nonatomic) UIColor *hoverBackgroundColor;
@property (nonatomic) UIFont *font;
@property (nonatomic) float fontSize;
@property (nonatomic) NSString *fontName;

#elif TARGET_OS_MAC

@property (nonatomic) NSColor *textColor;
@property (nonatomic) NSColor *shadowColor;
@property (nonatomic) NSColor *hoverBackgroundColor;
@property (nonatomic) NSFont *font;
@property (nonatomic) CursorBehaviour cursorBehaviour;
@property (nonatomic) WindowLevel windowLevel;
@property (nonatomic) NSString *customIcon;

#endif

+(SettingManager*)sharedManager;

- (NSArray *)streamingAccounts;
- (BOOL)isAccountStreaming:(Account *)account;
- (void)setStreamingState:(BOOL)streaming forAccount:(Account *)account;
- (NSArray<Account*> *)accounts;
- (Account *)accountWithIdentifier:(NSString *)identifier;
- (void)reloadAccounts;

@end
