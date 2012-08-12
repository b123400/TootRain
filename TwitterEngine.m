//
//  TwitterEngine.m
//  Canvas
//
//  Created by b123400 Chan on 11/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import "TwitterEngine.h"
#import "TwitterConnector.h"
#import "StreamingConsumer.h"
#import "StreamingDelegate.h"
#import "OAuthConsumer.h"
#import "CJSONDeserializer.h"

@interface TwitterEngine ()

-(NSArray*)searchTermsOfTweet:(NSDictionary*)tweet;
//find out which search term(s) caused the tweet to appare in our stream

@end

@implementation TwitterEngine

-(TwitterEngine*)initWithDelegate:(id)delegate{
	friendsID=[[NSMutableArray alloc]init];
	trackTerms=[[NSMutableArray alloc]init];
	streamConnection=nil;
	return [super initWithDelegate:delegate];
}
-(void)dealloc{
	[friendsID release];
	[trackTerms release];
	[super dealloc];
}
#pragma mark keyword
-(void)addKeyworkToTrack:(NSString*)keyword{
	if(![trackTerms containsObject:keyword]){
		[self stopStreaming];
		[trackTerms addObject:keyword];
		[self startStreamingTimeline];
	}
}
-(void)removeKeywordFromTracking:(NSString*)keyword{
	if([trackTerms containsObject:keyword]){
		[trackTerms removeObject:keyword];
		[self stopStreaming];
		[self startStreamingTimeline];
	}
}
#pragma mark streaming
-(BOOL)isStreaming{
	return streamConnection!=nil;
}

-(void)startStreamingTimeline{
	NSURL *url = [NSURL URLWithString:@"https://userstream.twitter.com/2/user.json"];
	NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
							   @"some",@"replies",
							   nil];
	if([trackTerms count]>0){
		[dict setObject:[trackTerms componentsJoinedByString:@","] forKey:@"track"];
	}
	[self startStreamingWithURL:url andParams:dict];
}
-(void)startStreamingWithURL:(NSURL*)url andParams:(NSDictionary*)params{
	if(streamConnection){
		[streamConnection cancel];
		[streamConnection release];
		streamConnection=nil;
	}
	OAConsumer* consumer = [[[OAConsumer alloc] initWithKey:[self consumerKey] secret:[self consumerSecret]] autorelease];	
	
	OAMutableURLRequest* streamingRequest = [[[OAMutableURLRequest alloc] initWithURL:url consumer:consumer token:self.accessToken realm:@"http://twitter.com" signatureProvider:nil] autorelease];
	[streamingRequest setTimeoutInterval:INT_MAX];
	[streamingRequest setHTTPMethod:@"POST"];
	
	NSMutableString *paramsString=[NSMutableString string];
	NSArray *keys=[params allKeys];
	for(int i=0;i<[keys count];i++){
		NSString *key=[keys objectAtIndex:i];
		[paramsString appendFormat:@"%@=%@",[key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding],[[params objectForKey:key]stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
		if(i!=[keys count]-1){
			[paramsString appendFormat:@"&"];
		}
	}
	[streamingRequest setHTTPBody:[paramsString dataUsingEncoding:NSUTF8StringEncoding]];
	
	[streamingRequest prepare];
	
	StreamingConsumer *streamConsumer=[[[StreamingConsumer alloc]init] autorelease];
	streamConsumer.delegate=self;
	StreamingDelegate *streamDelegate=[[[StreamingDelegate alloc]initWithConsumer:streamConsumer] autorelease];
	
	NSURLConnection *streamingConnection = [[[NSURLConnection alloc] initWithRequest:streamingRequest delegate:streamDelegate startImmediately:YES] autorelease];
	[streamingConnection start];
	streamConnection=[streamingConnection retain];
}
-(void)stopStreaming{
	if(![self isStreaming])return;
	[streamConnection cancel];
	[streamConnection release];
	streamConnection=nil;
}
#pragma mark delegate
- (void) consumerDidProcessStatus:(NSString*) statusString{
	NSError *error=nil;
	id object=[[CJSONDeserializer deserializer]deserialize:[statusString dataUsingEncoding:NSUTF8StringEncoding] error:&error];
	if([object isKindOfClass:[NSDictionary class]]){
		if([(NSDictionary*)object objectForKey:@"friends"]){
			//Twitter said: The first message delivered to a user stream is a list of the user’s friends.
			NSLog(@"received friends");
			[friendsID removeAllObjects];
			[friendsID addObjectsFromArray:[object objectForKey:@"friends"]];
		}else if([object objectForKey:@"delete"]){
			//check status/dm
		}else if([object objectForKey:@"limit"]){
			//ar....test
		}else if([object objectForKey:@"event"]){
			//this is a event
		}else if([object objectForKey:@"direct_message"]){
			//this is dm
			[[TwitterConnector sharedConnector] didReceivedStreamResult:object forDirectMessageFromEngine:self];
		}else if([object objectForKey:@"scrub_geo"]){
			//delete all geo datas from client
		}else if([object objectForKey:@"text"]&&[object objectForKey:@"user"]){
			//this should be a status?
			BOOL used=NO;
			if([friendsID containsObject:[[object objectForKey:@"user"] objectForKey:@"id"]]||[[[object objectForKey:@"user"] objectForKey:@"screen_name"] isEqualToString:self.username]){
				//this is in timeline
				[[TwitterConnector sharedConnector] didReceivedStreamResult:object forTimelineFromEngine:self];
				used=YES;
			}
			if([[[object objectForKey:@"text"]lowercaseString] rangeOfString:[[NSString stringWithFormat:@"@%@",self.username]lowercaseString]].location!=NSNotFound){
				//this is mention
				[[TwitterConnector sharedConnector]didReceivedStreamResult:object forMentionFromEngine:self];
				used=YES;
			}
			NSArray *searchTermsOfThisTweet=[self searchTermsOfTweet:object];
			for(NSString *thisSearchTerm in searchTermsOfThisTweet){
				used=YES;
				[[TwitterConnector sharedConnector]didReceivedStreamResult:object forSearchTerm:thisSearchTerm fromEngine:self];
			}
			if(!used){
				NSLog(@"%@",object);
			}
		}
	}
	if(!object){
		NSLog(@"Error: %@",[error description]);
		
	}
}
-(void)streamConnectionDidFinishLoading:(NSURLConnection *)connection{
	[connection release];
	[self startStreamingTimeline];
}
#pragma mark utility
-(NSArray*)searchTermsOfTweet:(NSDictionary*)tweet{
	NSMutableArray *matchedTerm=[NSMutableArray array];
	for(NSString *searchTerm in trackTerms){
		NSArray *orConditions=[searchTerm componentsSeparatedByString:@"OR"];
		NSMutableArray *allConditions=[NSMutableArray array];
		for(NSString *string in orConditions){
			[allConditions addObjectsFromArray:[string componentsSeparatedByString:@","]];
		}
		//one of the sub-condition match will do
		for(NSString *subCondition in allConditions){
			subCondition=[subCondition stringByReplacingOccurrencesOfString:@" AND " withString:@" "];
			//twitter treats AND same as space
			NSArray *finalConditions=[subCondition componentsSeparatedByString:@" "];
			int i=0;
			for(i=0;i<[finalConditions count];i++){
				NSString *thisCondition=[finalConditions objectAtIndex:i];
				if([[[tweet objectForKey:@"text"] lowercaseString] rangeOfString:[thisCondition lowercaseString]].location==NSNotFound){
					break;
				}
			}
			if(i>=[finalConditions count]){
				//all keywords are found
				[matchedTerm addObject:searchTerm];
			}
		}
	}
	return matchedTerm;
}

@end
