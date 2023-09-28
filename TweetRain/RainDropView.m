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
		NSRectFill(self.bounds);
	}
    [super drawRect:dirtyRect];
}
- (void)viewDidMoveToSuperview{
	if(self.superview){
		[delegate viewDidMovedToSuperview:self];
	}
}
- (void)mouseUp:(NSEvent *)theEvent{
	[super mouseUp:theEvent];
}
-(void)mouseEntered:(NSEvent *)theEvent{
	[super mouseEntered:theEvent];
}
-(void)mouseExited:(NSEvent *)theEvent{
	[super mouseExited:theEvent];
}

@end
