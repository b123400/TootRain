//
//  StreamingDelegate.h
//  TwitterCommonLibrary
//
//  Created by Tim Shi on 11-01-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StreamingDelegate.h"
#import "StreamingConsumer.h"

/*
 Twitter Engine's streaming connection keeps reference to this delegate object.

 This object has a reference to the consumer so that it can create task for the consumer and add it to the operation queue. 
 */

@interface StreamingDelegate : NSObject{
	
	//This is a strong reference because the consumer belongs to the delegate.
	StreamingConsumer* streamingConsumer;	
}

//Designated initializer, retain reference to the consumer.
- (id)initWithConsumer:(StreamingConsumer*)consumer;

//delegate method to url connection. When data is received we simply create a task with the recieved data and throw it to a queue for processing by the consumer.
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data;

//sends back the user credential
- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge;

@end
