//
//  RainDropContainerView.m
//  TweetRain
//
//  Created by b123400 on 21/3/15.
//
//

#import "RainDropContainerView.h"

@implementation RainDropContainerView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    
    for (UIView *thisView in self.subviews) {
        if ([thisView isKindOfClass:[UIImageView class]]) continue;
        CALayer *layer = thisView.layer.presentationLayer; // use presentation layer because it is animating
        if ([layer hitTest:point]) {
            return thisView;
        }
    }
    return [super hitTest:point withEvent:event];
}

@end
