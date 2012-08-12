//
//  SocialNetworkConnector.h
//  Canvas
//
//  Created by b123400 Chan on 10/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Status.h"
#import "Account.h"
#import "Request.h"
#import "UserRequest.h"
#import "StatusesRequest.h"
#import "SearchRequest.h"

@protocol SocialNetworkConnector <NSObject>

/*-(void)favouriteStatus:(Status*)status;
-(void)unfavouriteStatus:(Status*)status;*/

-(void)getUserProfile:(UserRequest*)request;
-(void)getUserStatuses:(StatusesRequest*)request;

-(void)searchTerm:(SearchRequest*)request;

@optional

-(void)startStreaming:(Request*)request;
-(void)searchTermUsingStream:(SearchRequest*)request;

@end
