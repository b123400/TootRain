//
//  RainDropTextFieldCell.m
//  flood
//
//  Created by b123400 on 12/8/12.
//
//

#import "RainDropTextFieldCell.h"
#import "SettingManager.h"

@implementation RainDropTextFieldCell

-(void)drawInteriorWithFrame:(NSRect)cellFrame inView:(NSView *)controlView{
	NSShadow *kShadow = [[[NSShadow alloc] init] autorelease];
    [kShadow setShadowColor:[[SettingManager sharedManager]shadowColor]];
    [kShadow setShadowBlurRadius:5.0f];
    [kShadow setShadowOffset:NSMakeSize(0.f, 0.0)];
	[kShadow set];
	
	NSShadow *kShadow2 = [[[NSShadow alloc] init] autorelease];
    [kShadow2 setShadowColor:[[SettingManager sharedManager]shadowColor]];
    [kShadow2 setShadowBlurRadius:5.0f];
    [kShadow2 setShadowOffset:NSMakeSize(0.f, 0.0)];
	[kShadow2 set];
    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
