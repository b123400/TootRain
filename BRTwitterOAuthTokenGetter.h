//
//  BRTwitterOAuthTokenGetter.h
//  Canvas
//
//  Created by b123400 on 24/06/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "BROAuthTokenGetter.h"

@protocol BRTwitterOAuthTokenGetterDelegate <BROAuthTokenGetterDelegate>

@optional
-(void)didReceivedRequestTokenURL:(NSURL*)url;

@end


@interface BRTwitterOAuthTokenGetter : BROAuthTokenGetter {

}

-(void)getRequestToken;
-(void)getAccessTokenWithPin:(NSString*)pin;

@end
