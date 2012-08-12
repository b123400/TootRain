//
//  EnginesManager.m
//  Canvas
//
//  Created by b123400 Chan on 8/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//
#import "StatusesManager.h"
#import "TwitterConnector.h"

@interface StatusesManager ()

-(NSString*)stringIDForAccount:(Account*)account;
-(void)extractObjectsToCacheFromObject:(id)object;

@end

@implementation StatusesManager

+(StatusesManager*)sharedManager{
	static StatusesManager *shared=nil;
	if(!shared){
		shared=[[StatusesManager alloc] init];
	}
	return shared;
}
-(id)init{
	self=[super init];
	statuses=[[NSMutableArray alloc]init];
	users=[[NSMutableArray alloc]init];
	return self;
}
-(void)dealloc{
	[statuses release];
	[users release];
	[super dealloc];
}

-(id)cachedObjectWhichDuplicate:(id)anotherObject{
	if([anotherObject isKindOfClass:[Status class]]){
		NSUInteger index=[statuses indexOfObject:anotherObject];
		if(index==NSNotFound)return nil;
		return [statuses objectAtIndex:index];
	}else if([anotherObject isKindOfClass:[User class]]){
		NSUInteger index=[users indexOfObject:anotherObject];
		if(index==NSNotFound)return nil;
		return [users objectAtIndex:index];
	}
	return nil;
}
-(void)cancelRequest:(Request*)request{
	switch (request.account.type) {
		case BRUserTypeTwitter:
			[[TwitterConnector sharedConnector] cancelRequest:request];
			break;
			
		default:
			break;
	}
}
/*
-(id)engineForAccount:(Account*)thisAccount{
	switch (thisAccount.type) {
		case BRUserTypeTwitter:
			return [self twitterEngineForAccount:thisAccount];
			break;
			
		default:
			break;
	}
	return nil;
}

-(TwitterEngine*)twitterEngineForAccount:(Account*)thisAccount{
	if(thisAccount.type!=BRUserTypeTwitter)return nil;
	NSString *stringID=[self stringIDForAccount:thisAccount];
	return [engines objectForKey:stringID];
}

-(void)setEngine:(id)engine forAccount:(Account*)thisAccount{
	[engines setObject:engine forKey:[self stringIDForAccount:thisAccount]];
}
*/
#pragma mark REST
-(void)startStreaming:(Request*)request{
	switch (request.account.type) {
		case BRUserTypeTwitter:
			[[TwitterConnector sharedConnector]startStreaming:request];
			break;
			
		default:
			break;
	}
}
-(void)searchTermUsingStream:(SearchRequest*)request{
	switch (request.account.type) {
		case BRUserTypeTwitter:
			[[TwitterConnector sharedConnector] searchTermUsingStream:request];
			break;
			
		default:
			break;
	}
}
-(void)getUserProfile:(UserRequest*)request{
	switch (request.account.type) {
		case BRUserTypeTwitter:
			[[TwitterConnector sharedConnector] getUserProfile:request];
			break;
			
		default:
			break;
	}
}
-(void)getUserStatuses:(StatusesRequest*)request{
	switch (request.type) {
		case BRUserTypeTwitter:
			[[TwitterConnector sharedConnector] getUserStatuses:request];
			break;
			
		default:
			break;
	}
}
#pragma mark delegate
-(void)request:(Request*)request didFinishedWithResult:(id)result{
	[self extractObjectsToCacheFromObject:result];
	[request.target performSelector:request.successSelector withObject:request withObject:result];
}
-(void)request:(Request*)request didReceivedResult:(id)result{
	[self extractObjectsToCacheFromObject:result];
	[request.target performSelector:request.successSelector withObject:request withObject:result];
}
-(void)request:(Request*)request didFailedWithError:(NSError*)error{
	[request.target performSelector:request.failSelector withObject:request withObject:error];
}
-(void)extractObjectsToCacheFromObject:(id)object{
	if([object isKindOfClass:[NSArray class]]){
		for(NSObject *subObject in object){
			[self extractObjectsToCacheFromObject:subObject];
		}
	}else if([object isKindOfClass:[NSDictionary class]]){
		for(id key in object){
			[self extractObjectsToCacheFromObject:[object objectForKey:key]];
		}
	}
	if(![self cachedObjectWhichDuplicate:object]){
		if([object isKindOfClass:[Status class]]){
			[statuses addObject:object];
		}else if([object isKindOfClass:[User class]]){
			[users addObject:object];
		}
	}
}
#pragma mark misc

-(NSString*)stringIDForAccount:(Account*)account{
	NSString *stringID=[NSString stringWithFormat:@"%@@%@",[account.userID stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[Account networkNameOfType:account.type]];
	return stringID;
}

@end
