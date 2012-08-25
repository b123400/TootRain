//
//  SettingManager.m
//  Canvas
//
//  Created by b123400 Chan on 4/2/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "SettingManager.h"
#import "Account.h"
#import "NSFileManager+DirectoryLocations.h"
#import "NSString+UUID.h"
#import "NSObject+Identifier.h"

@interface SettingManager ()

-(void)saveAccounts;

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

+(NSString*)tempPath{
	NSString *applicationSupportPath=[[NSFileManager defaultManager] applicationSupportDirectory];
	NSString *themeDirectoryPath=[applicationSupportPath stringByAppendingPathComponent:@"temp"];
	if(![[NSFileManager defaultManager] fileExistsAtPath:themeDirectoryPath]){
		NSError *error=nil;
		if(![[NSFileManager defaultManager] createDirectoryAtPath:themeDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error]){
			//cannnot 
			NSAlert *alert=[NSAlert alertWithError:error];
			[alert runModal];
		}
    }
	return themeDirectoryPath;
}

+(NSString*)themePath{
	NSString *applicationSupportPath=[[NSFileManager defaultManager] applicationSupportDirectory];
	NSString *themeDirectoryPath=[applicationSupportPath stringByAppendingPathComponent:@"themes"];
	if(![[NSFileManager defaultManager] fileExistsAtPath:themeDirectoryPath]){
		NSError *error=nil;
		if(![[NSFileManager defaultManager] createDirectoryAtPath:themeDirectoryPath withIntermediateDirectories:YES attributes:nil error:&error]){
			//cannnot 
			NSAlert *alert=[NSAlert alertWithError:error];
			[alert runModal];
		}
    }
	return themeDirectoryPath;
}

-(id)init{
	unzipProgressIndicator=[[NSMutableDictionary alloc] init];
	return [super init];
}

-(void)addAccount:(User*)account{
	NSArray *currentAccounts=[self accounts];
	if([currentAccounts containsObject:account])return;
	
	[[self accounts] addObject:account];
	[self saveAccounts];
}
-(void)deleteAccount:(User*)account{
	if(![[self accounts]containsObject:account])return;
	[[self accounts] removeObject:account];
	[self saveAccounts];
}
-(void)saveAccounts{
	NSMutableArray *accounts=[NSMutableArray arrayWithArray:[self accounts]];
	for(int i=0;i<[accounts count];i++){
		NSDictionary *dict=[[accounts objectAtIndex:i]dictionaryRepresentationWithAuthInformation:YES];
		[accounts replaceObjectAtIndex:i withObject:dict];
	}
	[[NSUserDefaults standardUserDefaults] setObject:accounts forKey:@"accounts"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
-(NSMutableArray*)accounts{
	if(!savedAccounts){
		savedAccounts=[[NSUserDefaults standardUserDefaults] objectForKey:@"accounts"];
		if(!savedAccounts){
			savedAccounts=[[NSMutableArray alloc]init];
		}else{
			savedAccounts=[[NSMutableArray alloc] initWithArray:savedAccounts];
		}
		for(int i=0;i<[savedAccounts count];i++){
			NSDictionary *thisAccount=[savedAccounts objectAtIndex:i];
			[savedAccounts replaceObjectAtIndex:i withObject:[Account userWithDictionary:thisAccount]];
		}
	}
	return savedAccounts;
}

#pragma mark
-(BOOL)overlapsMenuBar{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"overlapsMenuBar"];
}
-(BOOL)hideTweetAroundCursor{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"hideTweetAroundCursor"];
}
-(BOOL)showProfileImage{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"showProfileImage"];
}
-(BOOL)removeURL{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"removeURL"];
}
-(BOOL)underlineTweetsWithURL{
	return [[NSUserDefaults standardUserDefaults] boolForKey:@"underlineTweetsWithURL"];
}
-(float)opacity{
	float opacity=[[NSUserDefaults standardUserDefaults]floatForKey:@"opacity"];
	if(opacity==0){
		//opacity isn't set
		opacity=1;
	}
	return opacity;
}
-(NSColor*)textColor{
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"textColor"];
	if (theData == nil)return [NSColor whiteColor];
	return (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
}
-(NSColor*)shadowColor{
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"shadowColor"];
	if (theData == nil)return [NSColor blackColor];
	return (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
}
-(NSColor*)hoverBackgroundColor{
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"hoverBackgroundColor"];
	if (theData == nil)return [NSColor whiteColor];
	return (NSColor *)[NSUnarchiver unarchiveObjectWithData:theData];
}
-(NSFont*)font{
	NSData *theData=[[NSUserDefaults standardUserDefaults] dataForKey:@"font"];
	if (theData == nil)return [NSFont fontWithName:@"Arial" size:36];
	return (NSFont *)[NSUnarchiver unarchiveObjectWithData:theData];
}
@end
