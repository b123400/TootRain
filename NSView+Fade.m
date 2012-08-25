#import "NSView+Fade.h"

/**
 A category on NSView that allows fade in/out on setHidden:
 */
@implementation NSView(Fade)
/**
 Hides or unhides an NSView, making it fade in or our of existance.
 @param hidden YES to hide, NO to show
 @param fade if NO, just setHidden normally.
 */
- (IBAction)setHidden:(BOOL)hidden withFade:(BOOL)fade {
	if(!fade) {
		// The easy way out.  Nothing to do here...
		[self setHidden:hidden];
	} else {
		// FIXME: It would be better to check for the availability of NSViewAnimation at runtime intead
		// of at compile time.  I'm lazy, and I make two builds anyways, so I do it at compile. -ZSB
#if MAC_OS_X_VERSION_MIN_REQUIRED >= MAC_OS_X_VERSION_10_4
		// We're building for (at least) Tiger, so we can use NSViewAnimation
		if(!hidden) {
			// If we're unhiding, make sure we queue an unhide before the animation
			[self setHidden:NO];
		}
		NSMutableDictionary *animDict = [NSMutableDictionary dictionaryWithCapacity:2];
		[animDict setObject:self forKey:NSViewAnimationTargetKey];
		[animDict setObject:(hidden ? NSViewAnimationFadeOutEffect : NSViewAnimationFadeInEffect) forKey:NSViewAnimationEffectKey];
		NSViewAnimation *anim = [[NSViewAnimation alloc] initWithViewAnimations:[NSArray arrayWithObject:animDict]];
		[anim setDuration:0.2];
		[anim startAnimation];
#else
		// We're building for Panther, so just do a normal hide
		[self setHidden:hidden];
#endif
	}
	
}
@end