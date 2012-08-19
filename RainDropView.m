//
//  RainDropView.m
//  flood
//
//  Created by b123400 on 12/8/12.
//
//

#import "RainDropViewController.h"
#import "RainDropView.h"
#import "SettingManager.h"

@implementation RainDropView
@synthesize delegate,backgroundColor,needsShadow;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
	if(backgroundColor){
		[backgroundColor setFill];
		NSRectFill(dirtyRect);
	}
}
- (void)viewDidMoveToSuperview{
	if(self.superview){
		[delegate viewDidMovedToSuperview:self];
	}
}
- (void)mouseUp:(NSEvent *)theEvent{
	[delegate viewDidClicked:self];
	[super mouseUp:theEvent];
}
-(void)mouseEntered:(NSEvent *)theEvent{
	NSLog(@"entered");
	[super mouseEntered:theEvent];
}
-(void)mouseExited:(NSEvent *)theEvent{
	NSLog(@"out");
	[super mouseExited:theEvent];
}

@end
