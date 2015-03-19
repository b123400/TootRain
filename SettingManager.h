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

@interface SettingManager : NSObject{
    
}

@property (nonatomic, strong) ACAccountStore *accountStore;
@property (nonatomic, strong) ACAccountType *accountType;

+(SettingManager*)sharedManager;

- (ACAccount*)selectedAccount;
- (void)setSelectedAccount:(ACAccount*)account;
- (NSArray*)accounts;

-(BOOL)hideTweetAroundCursor;
-(BOOL)showProfileImage;
-(BOOL)removeURL;
-(BOOL)underlineTweetsWithURL;
-(float)opacity;

#if TARGET_OS_IPHONE

-(UIColor*)textColor;
-(UIColor*)shadowColor;
-(UIColor*)hoverBackgroundColor;
-(UIFont*)font;

#elif TARGET_OS_MAC

-(NSColor*)textColor;
- (void)setTextColor:(NSColor*)color;

-(NSColor*)shadowColor;
-(NSColor*)hoverBackgroundColor;
-(NSFont*)font;
-(NSNumber*)windowLevel;

#endif

@end
