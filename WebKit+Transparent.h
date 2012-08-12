//
//  WebKit+Transparent.h
//  Smarkin
//
//  Created by b123400 on 27/04/2011.
//  Copyright 2011 home. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface WebView (PRIVATE) 
-(void)setDrawsBackground:(BOOL)flag; 
-(BOOL)drawsBackground; 
@end