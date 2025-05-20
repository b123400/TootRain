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
    if ([[SettingManager sharedManager] showShadow]) {
        NSShadow *kShadow = [[NSShadow alloc] init];
        [kShadow setShadowColor:[[SettingManager sharedManager]shadowColor]];
        [kShadow setShadowBlurRadius:5.0f];
        [kShadow setShadowOffset:NSMakeSize(0.f, 0.0)];
        [kShadow set];
    }

    [super drawInteriorWithFrame:cellFrame inView:controlView];
}

@end
