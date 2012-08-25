//
//  StreamingConsumer.h
//  TwitterCommonLibrary
//
//  Created by Tim Shi on 11-01-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TwitterStreamingDelegate
@required
- (void) consumerDidProcessStatus:(NSString*) statusString;
@end

/*
	Responsible for parsing the status and doing something with it.
 */
@interface StreamingConsumer : NSObject {
	//Holds the data that comes in until it represents a complete status.
	NSMutableString* holderString;
	
	//Streaming data comes in and gets put on this queue.
	NSOperationQueue* operationQue;
	
	//a weak reference because the delegate doesn't belong to the consumer.
	id delegate;
}

@property(nonatomic, strong) NSOperationQueue* operationQue;

//Takes the data and processes it.
-(void) process:(NSString*)data;

//Other method can create a task with the data and throw it on the operation queue for processing later.
- (NSOperation*)taskWithData:(NSString*)data;

//Parses string with certain delimiter.
- (NSRange) parseStringWithDelimiter:(NSString*) delimiter forString:(NSString*) toBeParsed;

#pragma delegate
- (id)delegate;
- (void)setDelegate:(id)newDelegate;

@end