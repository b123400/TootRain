//
//  RainDropView.m
//  flood
//
//  Created by b123400 on 12/8/12.
//
//

#import "RainDropViewController.h"
#import "RainDropView.h"

@implementation RainDropView
@synthesize delegate;

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
    // Drawing code here.
	//[[NSColor redColor] setFill];
    //NSRectFill(dirtyRect);
}
- (void)viewDidMoveToSuperview{
	[delegate viewDidMovedToSuperview:self];
}

@end
