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

@interface SettingManager : NSObject{
	NSMutableDictionary *unzipProgressIndicator;
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
-(NSColor*)textColor;
-(NSColor*)shadowColor;
-(NSColor*)hoverBackgroundColor;
-(NSFont*)font;
-(NSNumber*)windowLevel;

@end
