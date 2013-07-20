//
//  TwitterConnector.m
//  Canvas
//
//  Created by b123400 Chan on 11/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//
#import "dispatch/dispatch.h"
#import "TwitterConnector.h"
#import "StreamingConsumer.h"
#import "StreamingDelegate.h"
#import "User.h"
#import "StatusesManager.h"
#import "NSString+UUID.h"
#import "TwitterStreamRequest.h"

@interface TwitterConnector ()

-(User*)userWithDictionary:(NSDictionary*)thisUserDict;
-(User*)user:(User*)existingUser WithDictionary:(NSDictionary*)thisUserDict;

-(Status*)statusWithDictionary:(NSDictionary*)dictionary;

@end

@implementation TwitterConnector

+(TwitterConnector*)sharedConnector{
	static TwitterConnector *shared=nil;
	if(!shared){
		shared=[[TwitterConnector alloc] init];
	}
	return shared;
}
-(id)init{
	requests=[[NSMutableDictionary alloc] init];
	return [super init];
}
-(TwitterEngine*)engineForAccount:(Account*)account{
	TwitterEngine *engine=[[TwitterEngine alloc] initWithDelegate:[TwitterConnector sharedConnector]];
	[engine setAccessToken:account.accessToken];
	[engine setUsername:account.username];
	[engine setUsesSecureConnection:YES];
	[engine setConsumerKey:kTwitterOAuthConsumerKey secret:kTwitterOAuthConsumerSecret];
	return engine;
}
#pragma mark -
-(void)cancelRequest:(Request*)request{
	TwitterEngine *engine=request.account.engine;
	if([request isKindOfClass:[SearchRequest class]]){
		[engine removeKeywordFromTracking:((SearchRequest*)request).searchTerm];
		for(NSString *key in [requests allKeys]){
			Request *thisRequest=[requests objectForKey:key];
			//dont stop the stream if there is other request require streaming
			if([thisRequest isKindOfClass:[SearchRequest class]]&&thisRequest.account==request.account){
				return;
				
			}
			if([thisRequest isKindOfClass:[TwitterEngine class]]&&thisRequest.account==request.account){
				return;
			}
		}
		[engine stopStreaming];
	}else if([request isKindOfClass:[TwitterStreamRequest class]]){
		if(![engine isStreaming])return;
		for(NSString *key in [requests allKeys]){
			Request *thisRequest=[requests objectForKey:key];
			if(thisRequest!=request&&[thisRequest isKindOfClass:[TwitterStreamRequest class]]&&[thisRequest.account isEqualTo:request.account]){
				return;
			}
		}
		[engine stopStreaming];
	}else{
		NSArray *allKeys=[requests allKeysForObject:request];
		if([allKeys count]<=0)return;
		NSString *requestID=[allKeys objectAtIndex:0];
		[engine closeConnection:requestID];
	}
	[requests removeObjectsForKeys:[requests allKeysForObject:request]];
}

-(void)startStreaming:(TwitterStreamRequest*)request{
	TwitterEngine *twitterEngine=request.account.engine;
	[twitterEngine startStreamingTimeline];
	[requests setObject:request forKey:[NSString stringWithNewUUID]];
	NSLog(@"start streaming");
}
-(void)searchTermUsingStream:(SearchRequest*)request{
	TwitterEngine *twitterEngine=request.account.engine;
	[twitterEngine addKeyworkToTrack:request.searchTerm];
	NSString *key=[NSString stringWithNewUUID];
	[requests setObject:request forKey:key];
}

-(void)getUserProfile:(UserRequest*)request{
	TwitterEngine *twitterEngine=request.account.engine;
	NSString *requestID=[twitterEngine getUserInformationFor:request.targetUsername];
	[requests setObject:request forKey:requestID];
}
-(void)getUserStatuses:(StatusesRequest*)request{
	TwitterEngine *engine=request.account.engine;
	
	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
	unsigned long long sinceID=[[formatter numberFromString:request.sinceStatus.statusID] unsignedLongValue];
	unsigned long long beforeID=[[formatter numberFromString:request.beforeStatus.statusID] unsignedLongValue];
	
	NSString *key;
	
	if(request.targetUsername){
		key=[engine getUserTimelineFor:request.targetUsername sinceID:sinceID withMaximumID:beforeID startingAtPage:-1 count:request.count];
	}else{
		key=[engine getUserTimelineFor:request.targetUserID sinceID:sinceID withMaximumID:beforeID startingAtPage:-1 count:request.count];
	}
	[requests setObject:request forKey:key];
}
-(void)sendStatus:(ComposeRequest*)request;{
	TwitterEngine *engine=request.account.engine;
	
	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
	NSString *key;
	if(request.inReplyTo){
		key=[engine sendUpdate:request.text inReplyTo:[[formatter numberFromString:request.inReplyTo.statusID] unsignedLongValue]];
	}else{
		key=[engine sendUpdate:request.text];
	}
	[requests setObject:request forKey:key];
}
-(void)retweetStatus:(ComposeRequest*)request{
	TwitterEngine *engine=request.account.engine;
	
	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
	NSString *key;
	if(request.inReplyTo){
		key=[engine sendRetweet:[[formatter numberFromString:request.inReplyTo.statusID] unsignedLongValue]];
	}else{
		return;
	}
	[requests setObject:request forKey:key];
}
-(void)favouriteStatus:(ComposeRequest*)request{
	TwitterEngine *engine=request.account.engine;
	
	NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
	NSString *key;
	if(request.inReplyTo){
		key=[engine markUpdate:[[formatter numberFromString:request.inReplyTo.statusID] unsignedLongValue] asFavorite:YES];
	}else{
		return;
	}
	[requests setObject:request forKey:key];
}
#pragma mark engine delegate
- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)connectionIdentifier{
	StatusesRequest *request=[requests objectForKey:connectionIdentifier];
	NSMutableArray *_statuses=[NSMutableArray array];
	for(NSDictionary *thisStatusDict in statuses){
		Status *thisStatus=[self statusWithDictionary:thisStatusDict];
		if(thisStatus){
			[_statuses addObject:thisStatus];
		}
	}
	[[StatusesManager sharedManager] request:request didReceivedResult:_statuses];
	[requests removeObjectForKey:connectionIdentifier];
}
- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)connectionIdentifier{
	UserRequest *request=[requests objectForKey:connectionIdentifier];
	NSMutableArray *users=[NSMutableArray array];
	for(NSDictionary *thisUserDict in userInfo){
		User *thisUser=[self userWithDictionary:thisUserDict];
		[users addObject:thisUser];
	}
	[[StatusesManager sharedManager] request:request didFinishedWithResult:users];
	[requests removeObjectForKey:connectionIdentifier];
}
- (void)requestFailed:(NSString *)connectionIdentifier withError:(NSError *)error{
	if(![NSThread isMainThread]){
		dispatch_async(dispatch_get_main_queue(), ^{
			[self requestFailed:connectionIdentifier withError:error];
		});
		return;
	}
	Request *thisRequest=[requests objectForKey:connectionIdentifier];
	[thisRequest.target performSelector:thisRequest.failSelector withObject:thisRequest withObject:error];
}
#pragma mark stream delegate
-(void)didReceivedStreamResult:(id)object forTimelineFromEngine:(TwitterEngine*)engine{
	Status *thisStatus=[self statusWithDictionary:object];
	NSMutableArray *matchedRequests=[NSMutableArray array];
	for(NSString *key in [requests allKeys]){
		TwitterStreamRequest *thisRequest=[requests objectForKey:key];
		if([thisRequest isKindOfClass:[TwitterStreamRequest class]]&&thisRequest.account.username==engine.username){
			[matchedRequests addObject:thisRequest];
		}
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		for(TwitterStreamRequest *thisRequest in matchedRequests){
			thisRequest.successSelector=thisRequest.timelineSelector;
			[[StatusesManager sharedManager] request:thisRequest didReceivedResult:thisStatus];
		}
	});
}
-(void)didReceivedStreamResult:(id)object forMentionFromEngine:(TwitterEngine*)engine{
	Status *thisStatus=[self statusWithDictionary:object];
	NSMutableArray *matchedRequests=[NSMutableArray array];
	for(NSString *key in [requests allKeys]){
		TwitterStreamRequest *thisRequest=[requests objectForKey:key];
		if([thisRequest isKindOfClass:[TwitterStreamRequest class]]&&thisRequest.account.username==engine.username){
			[matchedRequests addObject:thisRequest];
		}
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		for(TwitterStreamRequest *thisRequest in matchedRequests){
			thisRequest.successSelector=thisRequest.mentionSelector;
			[[StatusesManager sharedManager] request:thisRequest didReceivedResult:thisStatus];
		}
	});
}
-(void)didReceivedStreamResult:(id)object forDirectMessageFromEngine:(TwitterEngine*)engine{
	Status *thisStatus=[self statusWithDictionary:object];
	NSMutableArray *matchedRequests=[NSMutableArray array];
	for(NSString *key in [requests allKeys]){
		TwitterStreamRequest *thisRequest=[requests objectForKey:key];
		if([thisRequest isKindOfClass:[TwitterStreamRequest class]]&&thisRequest.account.username==engine.username){
			[matchedRequests addObject:thisRequest];
			
		}
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		for(TwitterStreamRequest *thisRequest in matchedRequests){
			thisRequest.successSelector=thisRequest.directMessageSelector;
			[[StatusesManager sharedManager] request:thisRequest didReceivedResult:thisStatus];
		}
	});
}
-(void)didReceivedStreamResult:(id)object forSearchTerm:(NSString*)term fromEngine:(TwitterEngine*)engine{
	NSMutableArray *matchedRequests=[NSMutableArray array];
	Status *thisStatus=nil;
	for(NSString *key in requests){
		Request *thisRequest=[requests objectForKey:key];
		if([thisRequest isKindOfClass:[SearchRequest class]]){
			if([((SearchRequest*)thisRequest).searchTerm isEqualToString:term]){
				if(!thisStatus){
					thisStatus=[self statusWithDictionary:object];
				}
				[matchedRequests addObject:thisRequest];
			}
		}
	}
	dispatch_async(dispatch_get_main_queue(), ^{
		for(SearchRequest *thisRequest in matchedRequests){
			[[StatusesManager sharedManager] request:thisRequest didReceivedResult:thisStatus];
		}
	});
}

#pragma mark convertion
-(User*)userWithDictionary:(NSDictionary*)thisUserDict{
	User *thisUser=[[User alloc]init];
	thisUser.type=BRUserTypeTwitter;
	thisUser=[self user:thisUser WithDictionary:thisUserDict];
	User *cachedUser=[[StatusesManager sharedManager] cachedObjectWhichDuplicate:thisUser];
	if(cachedUser)return [self user:cachedUser WithDictionary:thisUserDict];
	return thisUser;
}
-(User*)user:(User*)thisUser WithDictionary:(NSDictionary*)thisUserDict{
	thisUser.userID=[NSString stringWithFormat:@"%@",[thisUserDict objectForKey:@"id_str"]];
	thisUser.username=[thisUserDict objectForKey:@"screen_name"];
	thisUser.screenName=[thisUserDict objectForKey:@"name"];
	thisUser.profileImageURL=[NSURL URLWithString:[thisUserDict objectForKey:@"profile_image_url_https"]];
	thisUser.description=[thisUserDict objectForKey:@"description"];
	
	NSMutableDictionary *otherInfos=thisUser.otherInfos;
	NSArray *keys=[NSArray arrayWithObjects:@"created_at",@"follow_request_sent",@"followers_count",@"following",@"friends_count",@"geo_enabled",@"is_translator",@"lang",@"listed_count",
				   @"location",@"profile_background_color",@"profile_background_image_url_https",@"profile_link_color",@"profile_sidebar_border_color",@"profile_sidebar_fill_color",
				   @"profile_text_color",@"profile_use_background_image",@"protected",@"statuses_count",@"url",@"favourites_count",nil];
	for(__strong NSString *thisKey in keys){
		id object=[thisUserDict objectForKey:thisKey];
		if(object!=nil&&![object isKindOfClass:[NSNull class]]){
			if([thisKey isEqualToString:@"profile_background_image_url_https"]){
				thisKey=@"profile_background_image_url";
			}
			[otherInfos setObject:object forKey:thisKey];
		}
	}
	
	return thisUser;
}

-(Status*)statusWithDictionary:(NSDictionary*)dictionary{
	static NSDateFormatter *df=nil;
	
	Status *thisStatus=[[Status alloc]init];
	thisStatus.statusID=[dictionary objectForKey:@"id_str"];
	
	Status *cachedStatus=[[StatusesManager sharedManager]cachedObjectWhichDuplicate:thisStatus];
	if(cachedStatus)return cachedStatus;
	
	//parse user
	NSDictionary *userDict=[dictionary objectForKey:@"user"];
	User *thisUser=[self userWithDictionary:userDict];
	thisStatus.user=thisUser;
	
	//Direct message
	NSDictionary *sender=[dictionary objectForKey:@"sender"];
	if(sender){
		thisStatus.user=[self userWithDictionary:sender];
	}
	NSDictionary *recipient=[dictionary objectForKey:@"recipient"];
	if(recipient){
		[thisStatus.otherInfos setObject:[self userWithDictionary:recipient] forKey:@"recipient"];
	}
	
	//parse date
	if(!df){
		df = [[NSDateFormatter alloc] init];
		[df setTimeStyle:NSDateFormatterFullStyle];
		[df setFormatterBehavior:NSDateFormatterBehavior10_4];
		[df setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
		[df setDateFormat:@"EEE LLL dd HH:mm:ss Z yyyy"];
	}
	NSDate *createdAt=[df dateFromString:[dictionary objectForKey:@"created_at"]];
	thisStatus.createdAt=createdAt;
	
	if([dictionary objectForKey:@"retweeted_status"]){
		Status *retweetedStatus=[self statusWithDictionary:[dictionary objectForKey:@"retweeted_status"]];
		[retweetedStatus.otherInfos setObject:thisStatus.createdAt forKey:@"retweetedAt"];
		[retweetedStatus.otherInfos setObject:thisStatus.user forKey:@"retweetedBy"];
		return retweetedStatus;
	}
	
	thisStatus.text=[dictionary objectForKey:@"text"];
	
	thisStatus.liked=[[dictionary objectForKey:@"favorited"] boolValue];
	
	if([dictionary objectForKey:@"entities"]){
		thisStatus.entities=[dictionary objectForKey:@"entities"];
	}
	
	NSArray *keys=[NSArray arrayWithObjects:@"coordinates",@"retweet_count",@"geo",@"retweeted",@"source",@"place",@"in_reply_to_screen_name",@"in_reply_to_status_id", nil];
	for(NSString *key in keys){
		if([dictionary objectForKey:key]&&[dictionary objectForKey:key]!=[NSNull null]){
			[thisStatus.otherInfos setObject:[dictionary objectForKey:key] forKey:key];
		}
	}
	
	return thisStatus;
}

@end
