//
//  StreamingConsumer.m
//  TwitterCommonLibrary
//
//  Created by Tim Shi on 11-01-07.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "StreamingConsumer.h"


@implementation StreamingConsumer

@synthesize operationQue;

-(id)init{
	if (self = [super init]){
		holderString = [[NSMutableString alloc] init];
		operationQue = [[NSOperationQueue alloc] init];
		//process the task in serial
		[operationQue setMaxConcurrentOperationCount:1];					
	}
	return self;
}

#pragma mark delegate
- (id)delegate {
    return delegate;
}

- (void)setDelegate:(id)newDelegate {
    delegate = newDelegate;
}
#pragma end delegate

-(void) process:(NSString*)data{
	[holderString appendString:[data stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	
	//NSLog(@"holderString %@",holderString);
	
	NSRange range;
	
	range.location = [self parseStringWithDelimiter:@"%0D%0A" forString:holderString].location;
	range.length = [self parseStringWithDelimiter:@"%0D%0A" forString:holderString].length;
	
	if (range.location != NSNotFound){
		NSString* jsonString = [holderString substringWithRange:range];
				
		if ( [delegate respondsToSelector:@selector(consumerDidProcessStatus:)] ) {
			[delegate consumerDidProcessStatus:[jsonString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];		
		}
		
		if (range.location == 0 && range.length == 0){
			//this means there is a carriage return, but it's at the ver begining of the string (duplicate carriage return for example)
			//so we have to remove it right away.
			NSRange carriageReturnRange;
			carriageReturnRange.location = range.location;
			carriageReturnRange.length = 6;
			[holderString deleteCharactersInRange:carriageReturnRange];
		}else{
			//delete the status that was parsed plus the carriage return character
			range.length = range.length + 6;
			[holderString deleteCharactersInRange:range];			
		}
	}
}

- (NSRange) parseStringWithDelimiter:(NSString*) delimiter forString:(NSString*) toBeParsed{
	if([toBeParsed rangeOfString:delimiter].location != NSNotFound) {
			NSRange end = [toBeParsed rangeOfString:delimiter];			
			
			NSRange range;
			range.location = 0;
			range.length = end.location-0;
		
			return range;
	}
	return NSMakeRange(NSNotFound, 0);
}

#pragma mark operation
- (NSOperation*)taskWithData:(NSString*)data {
    NSInvocationOperation* theOp = [[[NSInvocationOperation alloc] initWithTarget:self
																		 selector:@selector(process:) object:data] autorelease];
	
	return theOp;
}

-(void)dealloc{
	[operationQue release];
	[holderString release];
	[super dealloc];
}

@end
