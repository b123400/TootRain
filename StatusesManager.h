//
//  EnginesManager.h
//  Canvas
//
//  Created by b123400 Chan on 8/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TwitterEngine.h"
#import "UserRequest.h"
#import "SearchRequest.h"
#import "StatusesRequest.h"
#import "ComposeRequest.h"
#import "Account.h"

@interface StatusesManager : NSObject{
	NSMutableArray *statuses;
	NSMutableArray *users;
}
+(StatusesManager*)sharedManager;

-(id)cachedObjectWhichDuplicate:(id)anotherObject;
-(void)cancelRequest:(Request*)request;

-(void)startStreaming:(Request*)request;
-(void)searchTermUsingStream:(SearchRequest*)request;

-(void)getUserProfile:(UserRequest*)request;
-(void)getUserStatuses:(StatusesRequest*)request;

-(void)sendStatus:(ComposeRequest*)request;
-(void)retweetStatus:(ComposeRequest*)request;
-(void)favouriteStatus:(ComposeRequest*)request;

-(void)request:(Request*)request didFinishedWithResult:(id)result;
-(void)request:(Request*)request didReceivedResult:(id)result;
-(void)request:(Request*)request didFailedWithError:(NSError*)error;

@end
