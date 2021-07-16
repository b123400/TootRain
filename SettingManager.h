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
#define kSelectedAccountChanged @"kSelectedAccountChanged"

#if TARGET_OS_IPHONE
#else
#define AUTO_SELECT_FIRST_ACCOUNT
#endif

typedef enum : NSUInteger {
    WindowLevelAboveMenuBar = 0,
    WindowLevelAboveAllWindows = 1,
    WindowLevelAboveDesktop = 2,
} WindowLevel;

@interface SettingManager : NSObject{
    
}

@property (nonatomic) BOOL hideStatusAroundCursor;
@property (nonatomic) BOOL showProfileImage;
@property (nonatomic) BOOL removeLinks;
@property (nonatomic) BOOL truncateStatus;
@property (nonatomic) NSInteger truncateStatusLength;
@property (nonatomic) float opacity;
@property (nonatomic) BOOL showShadow;

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
@property (nonatomic) WindowLevel windowLevel;

#endif

+(SettingManager*)sharedManager;

- (Account*)selectedAccount;
- (void)setSelectedAccount:(Account*)account;
- (NSArray<Account*> *)accounts;
- (void)reloadAccounts;

@end
