//
//  TwitterConnector.h
//  Canvas
//
//  Created by b123400 Chan on 11/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SocialNetworkConnector.h"
#import "TwitterEngine.h"
#import "Request.h"

#define kTwitterOAuthConsumerKey @"yfHpNCp8Q0KebyjIA36SQ"	//TODO: Add your consumer key here
#define kTwitterOAuthConsumerSecret @"LcwnUbHdUkotsj9IZlEv744pGWGyBVWxvxgpsB7lIc"	//TODO: add your consumer secret here.

@interface TwitterConnector : NSObject <SocialNetworkConnector>{
	NSMutableDictionary *requests;
}
+(TwitterConnector*)sharedConnector;
-(TwitterEngine*)engineForAccount:(Account*)account;

-(void)cancelRequest:(Request*)request;

-(void)didReceivedStreamResult:(id)object forTimelineFromEngine:(TwitterEngine*)engine;
-(void)didReceivedStreamResult:(id)object forMentionFromEngine:(TwitterEngine*)engine;
-(void)didReceivedStreamResult:(id)object forDirectMessageFromEngine:(TwitterEngine*)engine;
-(void)didReceivedStreamResult:(id)object forSearchTerm:(NSString*)term fromEngine:(TwitterEngine*)engine;

@end
