//
//  NSImage+Resize.m
//  TweetRain
//
//  Created by b123400 on 2021/07/07.
//

#import "NSImage+Resize.h"

@implementation NSImage (Resize)

-(NSImage *)resized:(NSSize)newSize
{
    if (![self isValid]) return nil;

    NSImage *smallImage = [[NSImage alloc] initWithSize: newSize];
    [smallImage lockFocus];
    [self setSize: newSize];
    [[NSGraphicsContext currentContext] setImageInterpolation:NSImageInterpolationHigh];
    [self drawAtPoint:NSZeroPoint fromRect:CGRectMake(0, 0, newSize.width, newSize.height) operation:NSCompositingOperationCopy fraction:1.0];
    [smallImage unlockFocus];
    return smallImage;
}


@end
