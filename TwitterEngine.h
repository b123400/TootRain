//
//  TwitterEngine.h
//  Canvas
//
//  Created by b123400 Chan on 11/4/12.
//  Copyright (c) 2012 home. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "MGTwitterEngine.h"
#import "Account.h"

@interface TwitterEngine : MGTwitterEngine{
	NSURLConnection *streamConnection;
	NSMutableArray *friendsID;
	NSMutableArray *trackTerms;
}

-(TwitterEngine*)initWithDelegate:(id)delegate;

-(BOOL)isStreaming;

-(void)startStreamingTimeline;
-(void)startStreamingWithURL:(NSURL*)url andParams:(NSDictionary*)params;

-(void)addKeyworkToTrack:(NSString*)keyword;
-(void)removeKeywordFromTracking:(NSString*)keyword;
-(void)stopStreaming;

-(void)streamConnectionDidFinishLoading:(NSURLConnection *)connection;

@end
