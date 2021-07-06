//
//  Account.h
//  Smarkin
//
//  Created by b123400 on 07/05/2011.
//  Copyright 2011 home. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "BRMastodonUser.h"

#if !TARGET_OS_IPHONE && TARGET_OS_MAC
#import <Cocoa/Cocoa.h>
#endif

@interface User : NSObject {
	NSString *username;
	NSString *screenName;
	NSString *userID;
	NSString *description;
	
	NSURL *profileImageURL;
	
	NSMutableDictionary *otherInfos;
}

@property (nonatomic,strong) NSString *username;
@property (nonatomic,strong) NSString *screenName;
@property (nonatomic,strong) NSString *userID;
@property (nonatomic,strong) NSString *description;

@property (nonatomic,strong) NSURL *profileImageURL;

@property (nonatomic,strong) NSMutableDictionary *otherInfos;

@end
