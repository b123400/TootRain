//
//  StreamingDelegate.m
//  TwitterCommonLibrary
//
//  Created by Tim Shi on 11-01-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StreamingDelegate.h"
#import "TwitterEngine.h"

@implementation StreamingDelegate

- (id)init
{
    return [self initWithConsumer:NULL] ;
}

-(id)initWithConsumer:(StreamingConsumer*)consumer {
	if(self = [super init]) {
		if (consumer != nil){
			streamingConsumer = consumer;
			[streamingConsumer retain];			
		}else{
			//TODO: throw an error here
			return nil;
		}
	}	
	return self;
}

//TODO: the implementation should take care of the credential using OAuth
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
#ifdef DEBUG
		NSLog(@"recieved authentication challenge");
#endif	
	[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
	return;
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

#ifdef DEBGUG	
		NSLog(@"recieved data %@", dataString);
#endif

	NSOperation* operation = [streamingConsumer taskWithData:dataString];
	
	[[streamingConsumer operationQue] addOperation:operation];

	[dataString release];	
}
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
	NSLog(@"Error: %@",[error description]);
}

#pragma mark required delegate methods
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedRespons{
	return cachedRespons;
}
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
	
}
- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite{
	
}
- (NSInputStream *)connection:(NSURLConnection *)connection needNewBodyStream:(NSURLRequest *)request{
	NSInputStream *inputStream=[NSInputStream inputStreamWithURL:request.URL];
	return inputStream;
}
- (NSURLRequest *)connection:(NSURLConnection *)connection willSendRequest:(NSURLRequest *)request redirectResponse:(NSURLResponse *)redirectResponse{
	return request;
}
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
	[((TwitterEngine*)streamingConsumer.delegate) streamConnectionDidFinishLoading:connection];
}
		
-(void) dealloc{
	[streamingConsumer release];
	[super dealloc];
}
@end
