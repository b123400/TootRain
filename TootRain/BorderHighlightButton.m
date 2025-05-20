//
//  BorderHighlightButton.m
//  TweetRain
//
//  Created by b123400 on 2023/01/26.
//

#import "BorderHighlightButton.h"

@implementation BorderHighlightButton

- (void)drawRect:(NSRect)rect {
    [super drawRect:rect];
    
    if (self.state == NSControlStateValueOn) {
        NSRect frameRect = [self bounds];
        NSRect newRect = NSMakeRect(frameRect.origin.x+2, frameRect.origin.y+2, frameRect.size.width-3, frameRect.size.height-3);
        
        NSBezierPath *textViewSurround = [NSBezierPath bezierPathWithRoundedRect:newRect xRadius:10 yRadius:10];
        [textViewSurround setLineWidth:2];
        [[NSColor controlAccentColor] set];
        [textViewSurround stroke];
    }
}

@end
