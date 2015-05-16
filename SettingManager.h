//
//  SettingManager.h
//  Canvas
//
//  Created by b123400 Chan on 4/2/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "User.h"
#import <Accounts/Accounts.h>
#import <Social/Social.h>

#define kRainDropAppearanceChangedNotification @"kRainDropAppearanceChangedNotification"
#define kWindowLevelChanged @"kWindowLevelChanged"

#if TARGET_OS_IPHONE
#else
#define AUTO_SELECT_FIRST_ACCOUNT
#endif

@interface SettingManager : NSObject{
    
}

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *accountType;

@property (nonatomic) BOOL hideTweetAroundCursor;
@property (nonatomic) BOOL showProfileImage;
@property (nonatomic) BOOL removeURL;
@property (nonatomic) BOOL underlineTweetsWithURL;
@property (nonatomic) float opacity;

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
@property (nonatomic) NSNumber *windowLevel;

#endif

+(SettingManager*)sharedManager;

- (ACAccount*)selectedAccount;
- (void)setSelectedAccount:(ACAccount*)account;
- (NSArray*)accounts;

@end
