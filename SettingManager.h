//
//  SettingManager.h
//  Canvas
//
//  Created by b123400 Chan on 4/2/12.
//  Copyright (c) 2012 home. All rights reserved.
//
#import "User.h"

@interface SettingManager : NSObject{
	NSMutableDictionary *unzipProgressIndicator;
}

+(SettingManager*)sharedManager;

+(NSString*)tempPath;
+(NSString*)themePath;
-(void)clearCachedThemes;

-(void)addAccount:(User*)account;
-(void)deleteAccount:(User*)account;
-(NSMutableArray*)accounts;

@end
