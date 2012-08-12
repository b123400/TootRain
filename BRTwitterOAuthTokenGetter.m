//
//  BRTwitterOAuthTokenGetter.m
//  Canvas
//
//  Created by b123400 on 24/06/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BRTwitterOAuthTokenGetter.h"
#import "OAServiceTicket.h"

@interface BROAuthTokenGetter()

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data;

@end

@implementation BRTwitterOAuthTokenGetter

-(void)getRequestToken{
	[super getRequestTokenWithURL:[NSURL URLWithString:@"https://api.twitter.com/oauth/request_token"]];
}
-(void)getAccessTokenWithPin:(NSString*)pin{
	NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/oauth/access_token"];
	[super getAccessTokenWithPin:pin url:url];
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	[super requestTokenTicket:ticket didFinishWithData:data];
	NSURL *authorizeURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://api.twitter.com/oauth/authorize?oauth_token=%@",[requestToken key]]];
	if(self.delegate){
		if([(NSObject*)self.delegate respondsToSelector:@selector(didReceivedRequestTokenURL:)]){
			[(id)self.delegate didReceivedRequestTokenURL:authorizeURL];
		}
	}
}

@end
