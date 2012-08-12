//
//  TransparentView.m
//  Smarkin
//
//  Created by b123400 on 27/04/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "TransparentView.h"


@implementation TransparentView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // set any NSColor for filling, say white:
	[[NSColor clearColor] set];
	NSRectFill(dirtyRect);
    [[NSColor clearColor] setFill];
    NSRectFill(dirtyRect);
	
	CGContextRef ctx = [[NSGraphicsContext currentContext] graphicsPort];
	CGContextClipToRect(ctx, NSRectToCGRect(dirtyRect));
	[[self layer] renderInContext:ctx];
}

-(void)mouseMoved:(NSEvent *)theEvent{
	NSLog(@"view called");
	[super mouseMoved:theEvent];
}

@end
