//
//  BROAuthTokenGetter.m
//  Canvas
//
//  Created by b123400 on 24/06/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "BROAuthTokenGetter.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"

@implementation BROAuthTokenGetter
@synthesize consumer,delegate,requestToken,accessToken;

-(id)initWithComsumerKey:(NSString*)consumerKey consumerSecret:(NSString*)consumerSecret{
	return [self initWithConsumer:[[OAConsumer alloc]initWithKey:consumerKey secret:consumerSecret]];
}
-(id)initWithConsumer:(OAConsumer*)_consumer{
	self.consumer=_consumer;
	return [self init];
}

-(void)getRequestTokenWithURL:(NSURL*)url{
	if(!consumer)return;
	OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
																   consumer:consumer
																	  token:[[SSToken alloc] init]   // we don't have a Token yet
																	  realm:nil   // our service provider doesn't specify a realm
														  signatureProvider:nil]; // use the default method, HMAC-SHA1
	[request setHTTPMethod:@"GET"];
	
	OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
	[fetcher fetchDataWithRequest:request
						 delegate:self
				didFinishSelector:@selector(requestTokenTicket:didFinishWithData:)
				  didFailSelector:@selector(requestTokenTicket:didFailWithError:)];
}


- (void)requestTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error{
	if(!ticket.didSucceed){
		NSLog(@"Failed to get request ticket: %@",error);
	}
}

- (void)requestTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		self.requestToken=[[SSToken alloc] initWithHTTPResponseBody:responseBody];
		if(self.delegate){
			if([(NSObject*)self.delegate respondsToSelector:@selector(didReceivedRequestToken:)]){
				[self.delegate didReceivedRequestToken:requestToken];
			}
		}
	}
}

#pragma mark Access token
-(void)getAccessTokenWithPin:(NSString*)pin url:(NSURL*)url{
	if(!consumer||!requestToken)return;
	[requestToken setPin:pin];

    OAMutableURLRequest *request = [[OAMutableURLRequest alloc] initWithURL:url
                                                                   consumer:consumer
                                                                      token:requestToken   // we don't have a Token yet
                                                                      realm:nil   // our service provider doesn't specify a realm
                                                          signatureProvider:nil]; // use the default method, HMAC-SHA1
	
    [request setHTTPMethod:@"GET"];
	
	
    OADataFetcher *fetcher = [[OADataFetcher alloc] init];
	
    [fetcher fetchDataWithRequest:request
                         delegate:self
                didFinishSelector:@selector(accessTokenTicket:didFinishWithData:)
                  didFailSelector:@selector(accessTokenTicket:didFailWithError:)];
}
- (void)accessTokenTicket:(OAServiceTicket *)ticket didFailWithError:(NSError *)error{
	if(!ticket.didSucceed){
		NSLog(@"Failed to get access ticket: %@",error);
	}
}

- (void)accessTokenTicket:(OAServiceTicket *)ticket didFinishWithData:(NSData *)data {
	if (ticket.didSucceed) {
		NSString *responseBody = [[NSString alloc] initWithData:data
													   encoding:NSUTF8StringEncoding];
		
		self.accessToken = [[SSToken alloc] initWithHTTPResponseBody:responseBody];
		if(self.delegate){
			if([(NSObject*)self.delegate respondsToSelector:@selector(didReceivedAccessToken:)]){
				[self.delegate didReceivedAccessToken:accessToken];
			}
		}		
	}
}

@end
