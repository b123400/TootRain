//
//  CustomTitleBar.m
//  Smarkin
//
//  Created by b123400 on 28/04/2011.
//  Copyright 2011 home. All rights reserved.
//

#import "CustomTitleBar.h"


@implementation CustomTitleBar
@synthesize delegate;

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
}

/*- (void)mouseDragged:(NSEvent *)theEvent{
	if(delegate){
		if([delegate respondsToSelector:@selector(mouseDragged:)]){
			[delegate mouseDragged:theEvent];
		}
	}
}*/
- (NSView *)hitTest:(NSPoint)aPoint
{
	NSView * clickedView = [super hitTest:aPoint];
	if([clickedView class]==[NSButton class]){
		return clickedView;
	}
	if([self mouse:aPoint inRect:[self frame]]){
		if (delegate)
		{
			return delegate;
		}
	}
    
    return clickedView;
}
@end
