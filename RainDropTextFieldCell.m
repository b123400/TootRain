//
//  RainDropTextFieldCell.m
//  flood
//
//  Created by b123400 on 12/8/12.
//
//

#import "RainDropTextFieldCell.h"

@implementation RainDropTextFieldCell

-(void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	NSShadow *kShadow = [[[NSShadow alloc] init] autorelease];
    [kShadow setShadowColor:[NSColor whiteColor]];
    [kShadow setShadowBlurRadius:10.0f];
    [kShadow setShadowOffset:NSMakeSize(0.f, 0.0)];
	
	[kShadow set];
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
