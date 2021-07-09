//
//  FloodWindow.m
//  flood
//
//  Created by b123400 on 11/8/12.
//
//

#import "FloodWindow.h"
#import "SettingManager.h"

@implementation FloodWindow

- (id)initWithContentRect:(NSRect)contentRect
				styleMask:(NSWindowStyleMask)windowStyle
				  backing:(NSBackingStoreType)bufferingType
					defer:(BOOL)deferCreation
{
	// Using NSBorderlessWindowMask results in a window without a title bar.
    self = [super initWithContentRect:contentRect styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO];
    if (self != nil) {
        [self setOpaque:NO];
		[self setBackgroundColor:[NSColor clearColor]];
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
@end
