//
//  WebKit+Transparent.m
//  Smarkin
//
//  Created by b123400 on 27/04/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "WebKit+Transparent.h"
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

@implementation WebView (PRIVATE) 

-(void)setDrawsBackground:(BOOL)flag{
	
}
-(BOOL)drawsBackground{
	return YES;
}

@end

#pragma clang diagnostic pop