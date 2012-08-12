//
//  FloodWindow.m
//  flood
//
//  Created by b123400 on 11/8/12.
//
//

#import "FloodWindow.h"

@implementation FloodWindow

- (id)initWithContentRect:(NSRect)contentRect
				styleMask:(NSUInteger)windowStyle
				  backing:(NSBackingStoreType)bufferingType
					defer:(BOOL)deferCreation
{
	// Using NSBorderlessWindowMask results in a window without a title bar.
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        [self setOpaque:NO];
		[self setBackgroundColor:[NSColor clearColor]];
		
		//[self setIgnoresMouseEvents:NO];
		[self setLevel:NSFloatingWindowLevel];
    }
    return self;
}
-(BOOL)isHiddenOrHasHiddenAncestor{
	return NO;
}
-(BOOL)acceptsMouseMovedEvents{
	return YES;
}
-(BOOL)acceptsFirstResponder{
	return YES;
}
-(BOOL)canBecomeKeyWindow{
	return YES;
}
- (void)mouseMoved:(NSEvent *)theEvent{
	return;
	NSLog(@"%@",[[self contentView] hitTest:theEvent.locationInWindow]);
	if([[self contentView] hitTest:theEvent.locationInWindow]!=[self contentView]){
		self.ignoresMouseEvents=NO;
		for(NSTrackingArea *trackingArea in [[self contentView]trackingAreas]){
			[[self contentView] removeTrackingArea:trackingArea];
		}
		NSTrackingArea *trackingArea=[[NSTrackingArea alloc] initWithRect:NSMakeRect(0, 0, self.frame.size.width, self.frame.size.height) options:(NSTrackingMouseMoved|NSTrackingAssumeInside|NSTrackingActiveAlways) owner:self userInfo:nil];
		[[self contentView] addTrackingArea:trackingArea];
	}else{
		self.ignoresMouseEvents=YES;
	}
}
@end
